using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSalesRefundLinks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "sales_refund_line",
                schema: "platform",
                columns: table => new
                {
                    refund_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    refund_row_no = table.Column<double>(type: "double precision", nullable: false),
                    original_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    original_row_no = table.Column<double>(type: "double precision", nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false),
                    restocked = table.Column<bool>(type: "boolean", nullable: false),
                    tax_a = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_b = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_sales_refund_line", x => new { x.refund_tx_number, x.refund_row_no });
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "sales_refund_line",
                schema: "platform");
        }
    }
}
