using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace xOpti.Infrastructure.Documents;

/// <summary>Renders a simple document model to PDF bytes using bundled fonts.</summary>
public sealed record DocumentRequest(IReadOnlyList<string> BarcodeValues, IReadOnlyList<string> Lines);

public sealed record DocumentFile(string Path, string ContentType, byte[] Content);

public interface IDocumentRenderer
{
    DocumentFile RenderInvoiceStub(DocumentRequest request);
}

public interface IFileStorage
{
    /// <summary>Persists content under a namespaced, date-scoped key and returns the final path.</summary>
    string Save(string namespacedKey, byte[] content, string contentType);

    bool TryRead(string namespacedKey, out byte[] content);
}

/// <summary>
/// QuestPDF renderer configured for Linux with bundled fonts (3of9 barcode).
/// The license type is Community (xOpti's commercial tier must be configured
/// at deployment; see Open Items in MIGRATION_NOTES).
/// </summary>
public sealed class QuestPdfDocumentRenderer : IDocumentRenderer
{
    private static readonly object FontRegistrationLock = new();
    private static string? _barcodeFamily;

    static QuestPdfDocumentRenderer()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    private readonly InfrastructureOptions _options;

    public QuestPdfDocumentRenderer(InfrastructureOptions options)
    {
        _options = options;
        RegisterFonts();
    }

    /// <summary>Family name of the bundled barcode font (3of9.TTF), discovered after registration.</summary>
    public static string BarcodeFamily =>
        _barcodeFamily ?? throw new InvalidOperationException("No barcode font registered; configure FontDirectories with 3of9.TTF available.");

    public DocumentFile RenderInvoiceStub(DocumentRequest request)
    {
        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.DefaultTextStyle(x => x.FontSize(11));
                page.Content().Column(col =>
                {
                    col.Item().Text("xOpti").Bold().FontSize(16);
                    foreach (var line in request.Lines)
                    {
                        col.Item().Text(line);
                    }

                    foreach (var barcode in request.BarcodeValues)
                    {
                        col.Item().Text($"*{barcode}*").FontFamily(BarcodeFamily).FontSize(24);
                    }
                });
            });
        });

        return new DocumentFile(
            "document.pdf",
            "application/pdf",
            document.GeneratePdf());
    }

    private void RegisterFonts()
    {
        lock (FontRegistrationLock)
        {
            if (_barcodeFamily is not null)
            {
                return;
            }

            foreach (var directory in _options.FontDirectories)
            {
                if (!Directory.Exists(directory))
                {
                    continue;
                }

            foreach (var fontFile in Directory.EnumerateFiles(directory, "*", SearchOption.AllDirectories)
                         .Where(f => f.EndsWith(".ttf", StringComparison.OrdinalIgnoreCase)
                                  || f.EndsWith(".otf", StringComparison.OrdinalIgnoreCase)))
            {
                if (!Path.GetFileNameWithoutExtension(fontFile).Equals("3of9", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                    using var stream = File.OpenRead(fontFile);
                    QuestPDF.Drawing.FontManager.RegisterFontFromStream(stream);

                    _barcodeFamily = QuestPDF.Drawing.FontManager.GetRegisteredFonts()
                        .Select(f => f.FamilyName)
                        .FirstOrDefault(n => n.Contains("3 of 9", StringComparison.OrdinalIgnoreCase)
                                          || n.Contains("3of9", StringComparison.OrdinalIgnoreCase)
                                          || n.Contains("3Of9", StringComparison.OrdinalIgnoreCase));
                }
            }
        }
    }
}

/// <summary>
/// Filesystem storage rooted at a configured volume path. Keys are namespaced
/// (module/date/file) and normalized; traversal outside the root is rejected,
/// matching the case-sensitive Linux file-path rules in the notes.
/// </summary>
public sealed class LocalFileStorage : IFileStorage
{
    private readonly string _root;

    public LocalFileStorage(string root)
    {
        if (string.IsNullOrWhiteSpace(root))
        {
            throw new ArgumentException("File storage root path is required.", nameof(root));
        }

        _root = Path.GetFullPath(root);
        Directory.CreateDirectory(_root);
    }

    public string Save(string namespacedKey, byte[] content, string contentType)
    {
        var target = Resolve(namespacedKey);
        Directory.CreateDirectory(Path.GetDirectoryName(target)!);
        File.WriteAllBytes(target, content);
        return Path.GetRelativePath(_root, target);
    }

    public bool TryRead(string namespacedKey, out byte[] content)
    {
        var target = Resolve(namespacedKey);
        if (File.Exists(target))
        {
            content = File.ReadAllBytes(target);
            return true;
        }

        content = Array.Empty<byte>();
        return false;
    }

    private string Resolve(string namespacedKey)
    {
        if (string.IsNullOrWhiteSpace(namespacedKey))
        {
            throw new ArgumentException("Storage key is required.", nameof(namespacedKey));
        }

        var candidate = Path.GetFullPath(Path.Combine(_root, namespacedKey));
        var rootWithSep = _root.EndsWith(Path.DirectorySeparatorChar) ? _root : _root + Path.DirectorySeparatorChar;

        if (!candidate.StartsWith(rootWithSep, StringComparison.Ordinal))
        {
            throw new UnauthorizedAccessException($"Storage key '{namespacedKey}' escapes the file storage root.");
        }

        return candidate;
    }
}
