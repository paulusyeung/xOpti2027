using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddPrescriptionVersionsAndAttachments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "medical_note",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    note = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    recorded_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    recorded_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_medical_note", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "patient_attachment",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    kind = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    prescription_type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    prescription_version_id = table.Column<long>(type: "bigint", nullable: true),
                    file_name = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    content_type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    size = table.Column<long>(type: "bigint", nullable: false),
                    storage_key = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    uploaded_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    uploaded_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_patient_attachment", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "rx_contact_version",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    version_number = table.Column<int>(type: "integer", nullable: false),
                    issued_on = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    prescriber_id = table.Column<int>(type: "integer", nullable: true),
                    brand = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    base_curve = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    diameter = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_power = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_cylinder = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_axis = table.Column<int>(type: "integer", nullable: true),
                    left_power = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_cylinder = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_axis = table.Column<int>(type: "integer", nullable: true),
                    replacement_schedule = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    notes = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    is_current = table.Column<bool>(type: "boolean", nullable: false),
                    verified_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    verified_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    verification_note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_rx_contact_version", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "rx_spectacle_version",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    version_number = table.Column<int>(type: "integer", nullable: false),
                    issued_on = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    prescriber_id = table.Column<int>(type: "integer", nullable: true),
                    right_sphere = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_cylinder = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_axis = table.Column<int>(type: "integer", nullable: true),
                    right_add = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_prism = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_base = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    right_pd = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_sphere = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_cylinder = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_axis = table.Column<int>(type: "integer", nullable: true),
                    left_add = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_prism = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_base = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    left_pd = table.Column<decimal>(type: "numeric(8,4)", precision: 8, scale: 4, nullable: true),
                    notes = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    is_current = table.Column<bool>(type: "boolean", nullable: false),
                    verified_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    verified_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    verification_note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_rx_spectacle_version", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_medical_note_customer_id",
                schema: "platform",
                table: "medical_note",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_patient_attachment_customer_id",
                schema: "platform",
                table: "patient_attachment",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_rx_contact_version_customer_id_is_current",
                schema: "platform",
                table: "rx_contact_version",
                columns: new[] { "customer_id", "is_current" },
                unique: true,
                filter: "is_current = true");

            migrationBuilder.CreateIndex(
                name: "ix_rx_contact_version_customer_id_version_number",
                schema: "platform",
                table: "rx_contact_version",
                columns: new[] { "customer_id", "version_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_rx_spectacle_version_customer_id_is_current",
                schema: "platform",
                table: "rx_spectacle_version",
                columns: new[] { "customer_id", "is_current" },
                unique: true,
                filter: "is_current = true");

            migrationBuilder.CreateIndex(
                name: "ix_rx_spectacle_version_customer_id_version_number",
                schema: "platform",
                table: "rx_spectacle_version",
                columns: new[] { "customer_id", "version_number" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "medical_note",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "patient_attachment",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "rx_contact_version",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "rx_spectacle_version",
                schema: "platform");
        }
    }
}
