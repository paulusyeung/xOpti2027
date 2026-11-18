using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddWholesaleLineTaxSnapshot : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "tax_a",
                schema: "platform",
                table: "wholesale_document_line",
                type: "numeric(19,4)",
                precision: 19,
                scale: 4,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "tax_b",
                schema: "platform",
                table: "wholesale_document_line",
                type: "numeric(19,4)",
                precision: 19,
                scale: 4,
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "tax_a",
                schema: "platform",
                table: "wholesale_document_line");

            migrationBuilder.DropColumn(
                name: "tax_b",
                schema: "platform",
                table: "wholesale_document_line");
        }
    }
}
