using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSalesRefundTenders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "sales_refund_tender",
                schema: "platform",
                columns: table => new
                {
                    refund_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    payment_line_no = table.Column<double>(type: "double precision", nullable: false),
                    original_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    original_payment_line_no = table.Column<double>(type: "double precision", nullable: false),
                    amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    method = table.Column<string>(type: "character varying(1)", maxLength: 1, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_sales_refund_tender", x => new { x.refund_tx_number, x.payment_line_no });
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "sales_refund_tender",
                schema: "platform");
        }
    }
}
