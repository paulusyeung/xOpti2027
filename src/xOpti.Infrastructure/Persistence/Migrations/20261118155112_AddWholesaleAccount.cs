using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddWholesaleAccount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "wholesale_account",
                schema: "platform",
                columns: table => new
                {
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    is_wholesale = table.Column<bool>(type: "boolean", nullable: false),
                    price_grade = table.Column<string>(type: "character varying(1)", maxLength: 1, nullable: true),
                    terms_code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    terms_days = table.Column<int>(type: "integer", nullable: false),
                    credit_limit = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    tax_treatment = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    representative_staff_code = table.Column<string>(type: "character varying(4)", maxLength: 4, nullable: true),
                    credit_hold = table.Column<bool>(type: "boolean", nullable: false),
                    notes = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    updated_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_wholesale_account", x => x.customer_id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_wholesale_account_representative_staff_code",
                schema: "platform",
                table: "wholesale_account",
                column: "representative_staff_code");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "wholesale_account",
                schema: "platform");
        }
    }
}
