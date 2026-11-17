using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddOpticalOrderDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "optical_order_event",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    occurred_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    actor = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    reference = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: true),
                    notes = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_optical_order_event", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "optical_order_rx",
                schema: "platform",
                columns: table => new
                {
                    tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    line_number = table.Column<double>(type: "double precision", nullable: false),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    prescription_type = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    prescription_version_id = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_optical_order_rx", x => new { x.tx_number, x.line_number });
                });

            migrationBuilder.CreateIndex(
                name: "ix_optical_order_event_tx_number_occurred_at",
                schema: "platform",
                table: "optical_order_event",
                columns: new[] { "tx_number", "occurred_at" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "optical_order_event",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "optical_order_rx",
                schema: "platform");
        }
    }
}
