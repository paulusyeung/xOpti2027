using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddInsurancePlansAndClaims : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "claim",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    claim_number = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    invoice_tx_number = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    plan_id = table.Column<long>(type: "bigint", nullable: false),
                    plan_version = table.Column<int>(type: "integer", nullable: false),
                    member_id = table.Column<long>(type: "bigint", nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    total_billed = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    covered_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    patient_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    approved_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    adjustment_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    paid_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    rejection_reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    resubmission_of = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_claim", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "claim_event",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    claim_id = table.Column<long>(type: "bigint", nullable: false),
                    event_type = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: true),
                    amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: true),
                    reason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    reference = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    occurred_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    actor = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_claim_event", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "claim_line",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    claim_id = table.Column<long>(type: "bigint", nullable: false),
                    line_number = table.Column<int>(type: "integer", nullable: false),
                    invoice_row_no = table.Column<int>(type: "integer", nullable: false),
                    sku = table.Column<string>(type: "character varying(13)", maxLength: 13, nullable: false),
                    billed_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    eligible = table.Column<bool>(type: "boolean", nullable: false),
                    coverage_percent = table.Column<decimal>(type: "numeric(7,4)", precision: 7, scale: 4, nullable: false),
                    covered_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    patient_amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    ineligible_reason = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_claim_line", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "claim_payment",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    claim_id = table.Column<long>(type: "bigint", nullable: false),
                    amount = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    method = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    reference = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    received_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    actor = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_claim_payment", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "coverage_rule",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    plan_id = table.Column<long>(type: "bigint", nullable: false),
                    category_code = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    sku = table.Column<string>(type: "character varying(13)", maxLength: 13, nullable: true),
                    coverage_percent = table.Column<decimal>(type: "numeric(7,4)", precision: 7, scale: 4, nullable: false),
                    annual_maximum = table.Column<decimal>(type: "numeric(19,4)", precision: 19, scale: 4, nullable: false),
                    requires_preauthorization = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_coverage_rule", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "insurance_member",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    customer_id = table.Column<int>(type: "integer", nullable: false),
                    plan_id = table.Column<long>(type: "bigint", nullable: false),
                    member_number = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: false),
                    group_number = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: true),
                    effective_from = table.Column<DateOnly>(type: "date", nullable: false),
                    effective_to = table.Column<DateOnly>(type: "date", nullable: true),
                    eligibility_note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_insurance_member", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "insurance_plan",
                schema: "platform",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    plan_code = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    version = table.Column<int>(type: "integer", nullable: false),
                    name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    payer_name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    is_current = table.Column<bool>(type: "boolean", nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    created_by = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_insurance_plan", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_claim_claim_number",
                schema: "platform",
                table: "claim",
                column: "claim_number",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_claim_invoice_tx_number",
                schema: "platform",
                table: "claim",
                column: "invoice_tx_number");

            migrationBuilder.CreateIndex(
                name: "ix_claim_event_claim_id_occurred_at",
                schema: "platform",
                table: "claim_event",
                columns: new[] { "claim_id", "occurred_at" });

            migrationBuilder.CreateIndex(
                name: "ix_claim_line_claim_id",
                schema: "platform",
                table: "claim_line",
                column: "claim_id");

            migrationBuilder.CreateIndex(
                name: "ix_claim_payment_claim_id",
                schema: "platform",
                table: "claim_payment",
                column: "claim_id");

            migrationBuilder.CreateIndex(
                name: "ix_coverage_rule_plan_id",
                schema: "platform",
                table: "coverage_rule",
                column: "plan_id");

            migrationBuilder.CreateIndex(
                name: "ix_insurance_member_customer_id",
                schema: "platform",
                table: "insurance_member",
                column: "customer_id");

            migrationBuilder.CreateIndex(
                name: "ix_insurance_plan_plan_code_is_current",
                schema: "platform",
                table: "insurance_plan",
                columns: new[] { "plan_code", "is_current" },
                unique: true,
                filter: "is_current = true");

            migrationBuilder.CreateIndex(
                name: "ix_insurance_plan_plan_code_version",
                schema: "platform",
                table: "insurance_plan",
                columns: new[] { "plan_code", "version" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "claim",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "claim_event",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "claim_line",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "claim_payment",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "coverage_rule",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "insurance_member",
                schema: "platform");

            migrationBuilder.DropTable(
                name: "insurance_plan",
                schema: "platform");
        }
    }
}
