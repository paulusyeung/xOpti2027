using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddWholesaleBackorders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "wholesale_backorder",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    original_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    original_row_no = table.Column<int>(type: "integer", nullable: false),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    sku = table.Column<string>(type: "character varying(13)", maxLength: 13, nullable: false),
                    ordered_quantity = table.Column<int>(type: "integer", nullable: false),
                    shipped_quantity = table.Column<int>(type: "integer", nullable: false),
                    remaining_quantity = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    fulfilled_by_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    fulfilled_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_backorder", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_backorder_customer_id",
                schema: "platform",
                table: "wholesale_backorder",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_backorder_original_tx_number_original_row_no",
                schema: "platform",
                table: "wholesale_backorder",
                columns: new[] { "original_tx_number", "original_row_no" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_backorder_status",
                schema: "platform",
                table: "wholesale_backorder",
                column: "status");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "wholesale_backorder",
                schema: "platform");
        }
    }
}
