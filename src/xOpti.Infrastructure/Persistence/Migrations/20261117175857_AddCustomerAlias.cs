using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddCustomerAlias : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "customer_alias",
                schema: "platform",
                columns: table => new
                {
                    alias_id = table.Column<int>(type: "integer", nullable: false),
                    canonical_id = table.Column<int>(type: "integer", nullable: false),
                    merged_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    merged_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_customer_alias", x => x.alias_id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_customer_alias_canonical_id",
                schema: "platform",
                table: "customer_alias",
                column: "canonical_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "customer_alias",
                schema: "platform");
        }
    }
}
