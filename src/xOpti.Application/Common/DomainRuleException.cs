namespace xOpti.Application.Common;

/// <summary>An application-level domain rule rejection (maps to 422 at the HTTP edge).</summary>
public class DomainRuleException(string message) : Exception(message);
