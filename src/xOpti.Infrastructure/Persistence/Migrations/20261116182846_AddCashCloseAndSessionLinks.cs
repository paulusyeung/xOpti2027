using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddCashCloseAndSessionLinks : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateOnly>(
                name: "business_date",
                schema: "platform",
                table: "cash_session",
                type: "date",
                nullable: false,
                defaultValue: new DateOnly(1, 1, 1));

            migrationBuilder.CreateTable(
                name: "cash_daily_close",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    branch_code = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    business_date = table.Column<DateOnly>(type: "date", nullable: false),
                    status = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    finalized_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    finalized_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    total_sales = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    total_refunds = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_a = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_b = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    cash_tenders = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    card_tenders = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    other_tenders = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    paid_in = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    paid_out = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    pickups = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    deposits = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    expected_cash = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    counted_cash = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    variance = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    snapshot_json = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cash_daily_close", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "cash_session_tx",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    session_id = table.Column<long>(type: "bigint", nullable: false),
                    tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    tx_type = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    occurred_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cash_session_tx", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_cash_daily_close_branch_code_business_date",
                schema: "platform",
                table: "cash_daily_close",
                columns: new[] { "branch_code", "business_date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_cash_session_tx_tx_number",
                schema: "platform",
                table: "cash_session_tx",
                column: "tx_number",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "cash_daily_close",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "cash_session_tx",
                schema: "platform");

            migrationBuilder.DropColumn(
                name: "business_date",
                schema: "platform",
                table: "cash_session");
        }
    }
}
