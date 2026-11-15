using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddCashManagement : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "cash_count",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    session_id = table.Column<long>(type: "bigint", nullable: false),
                    kind = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    amount = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: false),
                    counted_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    counted_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    variance = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: true),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cash_count", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "cash_movement",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    session_id = table.Column<long>(type: "bigint", nullable: false),
                    kind = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    amount = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: false),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    occurred_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    actor = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    destination_reference = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cash_movement", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "cash_session",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    branch_code = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    terminal_code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    status = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    opened_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    opened_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    opening_float = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: false),
                    suspended_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    closed_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    closed_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    expected_cash = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: true),
                    counted_cash = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: true),
                    variance = table.Column<decimal>(type: "numeric(12,4)", precision: 12, scale: 4, nullable: true),
                    variance_reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_cash_session", x => x.id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "cash_count",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "cash_movement",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "cash_session",
                schema: "platform");
        }
    }
}
