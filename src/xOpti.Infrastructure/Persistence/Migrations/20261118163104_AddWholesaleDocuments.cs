using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddWholesaleDocuments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "wholesale_document",
                schema: "platform",
                columns: table => new
                {
                    tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    kind = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    status = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    terms_code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    terms_days = table.Column<int>(type: "integer", nullable: false),
                    due_date = table.Column<DateOnly>(type: "date", nullable: true),
                    shipping_method = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: true),
                    ship_to_name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: true),
                    ship_to_address = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    shipping_instructions = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    purchase_order_number = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    original_invoice_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    updated_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    posted_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    posted_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    voided_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    voided_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    void_reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_document", x => x.tx_number);
                });

            migrationBuilder.CreateTable(
                name: "wholesale_tender",
                schema: "platform",
                columns: table => new
                {
                    tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    line_no = table.Column<int>(type: "integer", nullable: false),
                    method = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    reference = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_tender", x => new { x.tx_number, x.line_no });
                });

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_document_kind",
                schema: "platform",
                table: "wholesale_document",
                column: "kind");

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_document_original_invoice_number",
                schema: "platform",
                table: "wholesale_document",
                column: "original_invoice_number");

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_document_status",
                schema: "platform",
                table: "wholesale_document",
                column: "status");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "wholesale_document",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "wholesale_tender",
                schema: "platform");
        }
    }
}
