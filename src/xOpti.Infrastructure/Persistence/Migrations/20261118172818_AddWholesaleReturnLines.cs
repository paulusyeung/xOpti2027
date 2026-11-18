using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddWholesaleReturnLines : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "wholesale_return_line",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    return_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    return_row_no = table.Column<int>(type: "integer", nullable: false),
                    original_invoice_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    original_row_no = table.Column<int>(type: "integer", nullable: false),
                    sku = table.Column<string>(type: "character varying(13)", maxLength: 13, nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false),
                    unit_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    discount_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_a = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_b = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_code = table.Column<string>(type: "character varying(1)", maxLength: 1, nullable: true),
                    restock = table.Column<bool>(type: "boolean", nullable: false),
                    disposition_reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_return_line", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_return_line_original_invoice_number_original_row_",
                schema: "platform",
                table: "wholesale_return_line",
                columns: new[] { "original_invoice_number", "original_row_no" });

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_return_line_return_tx_number_return_row_no",
                schema: "platform",
                table: "wholesale_return_line",
                columns: new[] { "return_tx_number", "return_row_no" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "wholesale_return_line",
                schema: "platform");
        }
    }
}
