using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddWholesalePriceLists : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "wholesale_document_line",
                schema: "platform",
                columns: table => new
                {
                    tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    row_no = table.Column<double>(type: "double precision", nullable: false),
                    price_list_code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    price_list_version = table.Column<int>(type: "integer", nullable: false),
                    list_unit_price = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    applied_unit_price = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    is_override = table.Column<bool>(type: "boolean", nullable: false),
                    override_reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    override_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_document_line", x => new { x.tx_number, x.row_no });
                });

            migrationBuilder.CreateTable(
                name: "wholesale_price_list",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    version = table.Column<int>(type: "integer", nullable: false),
                    is_current = table.Column<bool>(type: "boolean", nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_price_list", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "wholesale_price_list_item",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    price_list_id = table.Column<long>(type: "bigint", nullable: false),
                    sku = table.Column<string>(type: "character varying(13)", maxLength: 13, nullable: false),
                    price = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_price_list_item", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_price_list_code_is_current",
                schema: "platform",
                table: "wholesale_price_list",
                columns: new[] { "code", "is_current" },
                unique: true,
                filter: "is_current = true");

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_price_list_code_version",
                schema: "platform",
                table: "wholesale_price_list",
                columns: new[] { "code", "version" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_price_list_item_price_list_id_sku",
                schema: "platform",
                table: "wholesale_price_list_item",
                columns: new[] { "price_list_id", "sku" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "wholesale_document_line",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "wholesale_price_list",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "wholesale_price_list_item",
                schema: "platform");
        }
    }
}
