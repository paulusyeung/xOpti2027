using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddReportingFramework : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "reporting");

            migrationBuilder.CreateTable(
                name: "analytics_saved_view",
                schema: "reporting",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    view_key = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                    name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    owner_user_id = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    is_shared = table.Column<bool>(type: "boolean", nullable: false),
                    config_json = table.Column<string>(type: "character varying(20000)", maxLength: 20000, nullable: false),
                    created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_analytics_saved_view", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "read_model_state",
                schema: "reporting",
                columns: table => new
                {
                    model_key = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    as_of = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    refresh_started_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    refresh_completed_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    row_count = table.Column<long>(type: "bigint", nullable: true),
                    last_error = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_read_model_state", x => x.model_key);
                });

            migrationBuilder.CreateTable(
                name: "report_run",
                schema: "reporting",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    catalogue_id = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    actor = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    branch = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: true),
                    parameters_json = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    generated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    duplicate = table.Column<bool>(type: "boolean", nullable: false),
                    row_count = table.Column<int>(type: "integer", nullable: false),
                    truncated = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_report_run", x => x.id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_analytics_saved_view_owner_user_id_view_key",
                schema: "reporting",
                table: "analytics_saved_view",
                columns: new[] { "owner_user_id", "view_key" });

            migrationBuilder.CreateIndex(
                name: "ix_report_run_catalogue_id_generated_at",
                schema: "reporting",
                table: "report_run",
                columns: new[] { "catalogue_id", "generated_at" });

            migrationBuilder.Sql(@"
DO $reporting$
BEGIN
    IF to_regclass('public.inventory') IS NULL THEN
RETURN;
    END IF;
    EXECUTE $sql$
                CREATE VIEW reporting.v_customer AS
                SELECT c.id AS customer_id, c.full_name, c.vip_code, c.home_phone, c.email,
                       c.home_city, c.home_province, c.credit_limit,
                       COALESCE(ca.ttl_amt_purchased, 0) AS ttl_purchased,
                       ca.last_purchase_date
                FROM public.customer c
                LEFT JOIN public.customer_accounts ca ON ca.customer_id = c.id;
                CREATE VIEW reporting.v_inventory AS
                SELECT i.sku, i.name, i.department_code, i.class_code, i.category_code,
                       i.supplier_code, i.brand_code, i.qty_total_on_hand, i.average_cost,
                       COALESCE(rp.retail_price, 0) AS retail_price,
                       COALESCE(wp.selling_price_grade_a, 0) AS wholesale_a,
                       COALESCE(wp.selling_price_grade_b, 0) AS wholesale_b,
                       COALESCE(wp.selling_price_grade_c, 0) AS wholesale_c
                FROM public.inventory i
                LEFT JOIN public.retail_price rp ON rp.sku = i.sku
                LEFT JOIN public.wholesale_price wp ON wp.sku = i.sku;
                CREATE VIEW reporting.v_purchasing AS
                SELECT h.tx_number, h.date_of_entry, h.tx_type, h.supplier_code,
                       s.supplier_name, d.sku, d.qty, d.unit_cost, d.amount, h.total_amount
                FROM public.tx_header h
                JOIN public.tx_details d ON d.tx_number = h.tx_number
                LEFT JOIN public.supplier s ON s.supplier_code = h.supplier_code
                WHERE h.tx_type IN ('SR', 'RJ');
                CREATE VIEW reporting.v_sales AS
                SELECT h.tx_number, h.date_of_entry, h.tx_type, h.customer_id,
                       c.full_name AS customer_name, sp.staff_code, h.status,
                       d.row_no, d.sku, d.qty, d.unit_amount, d.amount, d.tax_code,
                       d.unit_cost,
                       (d.amount - d.unit_cost * d.qty) AS margin
                FROM public.tx_header h
                JOIN public.tx_details d ON d.tx_number = h.tx_number
                LEFT JOIN public.customer c ON c.id = h.customer_id
                LEFT JOIN LATERAL (
                    SELECT staff_code FROM public.tx_sale_person p
                    WHERE p.tx_number = h.tx_number ORDER BY sales_row_no LIMIT 1
                ) sp ON true
                WHERE h.tx_type IN ('RC', 'RS', 'SA');
                CREATE VIEW reporting.v_cost AS
                SELECT tx_number, date_of_entry, customer_id, customer_name, staff_code,
                       sku, qty, amount AS sales, (unit_cost * qty) AS cost,
                       margin,
                       CASE WHEN amount = 0 THEN 0
                            ELSE ROUND(margin / amount * 100, 2) END AS margin_percent
                FROM reporting.v_sales
                WHERE tx_type IN ('RC', 'RS');
                CREATE VIEW reporting.v_orders AS
                SELECT h.tx_number, h.date_of_entry, h.customer_id, c.full_name AS customer_name,
                       h.status, h.total_amount, h.this_paid,
                       (h.total_amount - h.this_paid) AS balance,
                       GREATEST(0, EXTRACT(DAY FROM (now() - h.date_of_entry))::int) AS age_days,
                       h.ref_number
                FROM public.tx_header h
                LEFT JOIN public.customer c ON c.id = h.customer_id
                WHERE h.tx_type = 'SA';
                CREATE VIEW reporting.v_wholesale AS
                SELECT h.tx_number, h.date_of_entry, h.tx_type, h.customer_id,
                       c.full_name AS customer_name, h.status, d.row_no, d.sku, d.qty,
                       d.unit_amount, d.amount, h.total_amount, h.this_paid,
                       (h.total_amount - h.this_paid) AS balance
                FROM public.tx_header h
                LEFT JOIN public.customer c ON c.id = h.customer_id
                LEFT JOIN public.tx_details d ON d.tx_number = h.tx_number
                WHERE h.tx_type IN ('WC', 'WR');
                CREATE VIEW reporting.v_prescriptions AS
                SELECT v.customer_id, c.full_name AS customer_name, 'spectacle' AS type,
                       v.version_number, v.issued_on, v.prescriber_id AS prescriber,
                       v.right_sphere, v.right_cylinder, v.right_axis,
                       v.left_sphere, v.left_cylinder, v.left_axis, v.verified_at
                FROM platform.rx_spectacle_version v
                LEFT JOIN public.customer c ON c.id = v.customer_id
                UNION ALL
                SELECT v.customer_id, c.full_name, 'contact', v.version_number, v.issued_on,
                       v.prescriber_id, v.right_power, v.right_cylinder, v.right_axis,
                       v.left_power, v.left_cylinder, v.left_axis, v.verified_at
                FROM platform.rx_contact_version v
                LEFT JOIN public.customer c ON c.id = v.customer_id;
                CREATE VIEW reporting.v_claims AS
                SELECT cl.claim_number, cl.invoice_tx_number, cl.customer_id,
                       c.full_name AS customer_name, p.plan_code, p.payer_name,
                       cl.status, cl.created_at, cl.total_billed, cl.covered_amount,
                       cl.approved_amount, cl.paid_amount
                FROM platform.claim cl
                JOIN platform.insurance_plan p ON p.id = cl.plan_id
                LEFT JOIN public.customer c ON c.id = cl.customer_id;
                CREATE VIEW reporting.v_cash AS
                SELECT business_date, branch_code, terminal_code, status, opening_float,
                       expected_cash, counted_cash, variance, closed_at
                FROM platform.cash_session;
                CREATE VIEW reporting.v_tax AS
                SELECT tx_number, date_of_entry, tx_type, customer_id,
                       total_sale AS net_sales, tax_a, tax_b, total_amount
                FROM public.tx_header
                WHERE tx_type IN ('RC', 'RS', 'WC', 'WR');
                CREATE VIEW reporting.v_catalogue AS
                SELECT 'inventory' AS kind, sku AS code, name, category_code AS extra
                FROM public.inventory
                UNION ALL SELECT 'department', department_code, department_name, ''
                FROM public.department
                UNION ALL SELECT 'class', class_code, class_name, department
                FROM public.class
                UNION ALL SELECT 'category', category_code, category_name,
                       department_code || '/' || class_code
                FROM public.category
                UNION ALL SELECT 'brand', brand_code, brand_description, ''
                FROM public.brand
                UNION ALL SELECT 'supplier', supplier_code, supplier_name, ''
                FROM public.supplier;
                CREATE MATERIALIZED VIEW reporting.mv_olap_sales_by_cost AS
                SELECT to_char(h.date_of_entry, 'YYYY-MM') AS period,
                       COALESCE(cs.branch_code, '01') AS branch,
                       i.department_code, i.class_code, i.category_code, d.sku,
                       SUM(d.qty)::int AS qty,
                       SUM(d.amount) AS sales,
                       SUM(d.unit_cost * d.qty) AS cost,
                       SUM(d.amount - d.unit_cost * d.qty) AS margin
                FROM public.tx_header h
                JOIN public.tx_details d ON d.tx_number = h.tx_number
                LEFT JOIN public.inventory i ON i.sku = d.sku
                LEFT JOIN LATERAL (
                    SELECT s.branch_code
                    FROM platform.cash_session_tx t
                    JOIN platform.cash_session s ON s.id = t.session_id
                    WHERE t.tx_number = h.tx_number LIMIT 1
                ) cs ON true
                WHERE h.tx_type = 'RC'
                   OR (h.tx_type = 'RS' AND h.ref_number LIKE 'RC%')
                GROUP BY 1, 2, 3, 4, 5, 6;
                CREATE UNIQUE INDEX ux_mv_olap_sales_by_cost
                ON reporting.mv_olap_sales_by_cost
                (period, branch, department_code, class_code, category_code, sku);
                CREATE MATERIALIZED VIEW reporting.mv_olap_sales_by_lsp AS
                SELECT to_char(h.date_of_entry, 'YYYY-MM') AS period,
                       COALESCE(cs.branch_code, '01') AS branch,
                       sp.staff_code,
                       SUM(d.qty)::int AS qty,
                       SUM(d.amount) AS sales,
                       SUM(d.unit_lsp * d.qty) AS cost,
                       SUM(d.amount - d.unit_lsp * d.qty) AS margin
                FROM public.tx_header h
                JOIN public.tx_details d ON d.tx_number = h.tx_number
                LEFT JOIN LATERAL (
                    SELECT staff_code FROM public.tx_sale_person p
                    WHERE p.tx_number = h.tx_number ORDER BY sales_row_no LIMIT 1
                ) sp ON true
                LEFT JOIN LATERAL (
                    SELECT s.branch_code
                    FROM platform.cash_session_tx t
                    JOIN platform.cash_session s ON s.id = t.session_id
                    WHERE t.tx_number = h.tx_number LIMIT 1
                ) cs ON true
                WHERE h.tx_type = 'RC'
                   OR (h.tx_type = 'RS' AND h.ref_number LIKE 'RC%')
                GROUP BY 1, 2, 3;
                CREATE UNIQUE INDEX ux_mv_olap_sales_by_lsp
                ON reporting.mv_olap_sales_by_lsp (period, branch, staff_code);
                CREATE MATERIALIZED VIEW reporting.mv_olap_orders_in_progress AS
                SELECT h.tx_number, h.date_of_entry, h.customer_id,
                       c.full_name AS customer_name, h.status, h.total_amount,
                       h.this_paid, (h.total_amount - h.this_paid) AS balance,
                       GREATEST(0, EXTRACT(DAY FROM (now() - h.date_of_entry))::int) AS age_days,
                       h.ref_number
                FROM public.tx_header h
                LEFT JOIN public.customer c ON c.id = h.customer_id
                WHERE h.tx_type = 'SA' AND h.status = '0';
                CREATE UNIQUE INDEX ux_mv_olap_orders_in_progress
                ON reporting.mv_olap_orders_in_progress (tx_number);
                CREATE MATERIALIZED VIEW reporting.mv_olap_category_summary AS
                SELECT department_code, class_code, category_code,
                       SUM(qty)::int AS qty, SUM(sales) AS sales, SUM(cost) AS cost,
                       SUM(margin) AS margin
                FROM reporting.mv_olap_sales_by_cost
                GROUP BY 1, 2, 3;
                CREATE UNIQUE INDEX ux_mv_olap_category_summary
                ON reporting.mv_olap_category_summary (department_code, class_code, category_code);
                INSERT INTO reporting.read_model_state (model_key, as_of)
                VALUES ('sales_by_cost', now()), ('sales_by_lsp', now()),
                       ('orders_in_progress', now()), ('category_summary', now()),
                       ('report_views', now())
                ON CONFLICT (model_key) DO NOTHING;
    $sql$;
END
$reporting$;
");

        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "analytics_saved_view",
                schema: "reporting");

            migrationBuilder.DropTable(
                name: "read_model_state",
                schema: "reporting");

            migrationBuilder.DropTable(
                name: "report_run",
                schema: "reporting");
            migrationBuilder.Sql("DROP MATERIALIZED VIEW IF EXISTS reporting.mv_olap_category_summary;");
            migrationBuilder.Sql("DROP MATERIALIZED VIEW IF EXISTS reporting.mv_olap_orders_in_progress;");
            migrationBuilder.Sql("DROP MATERIALIZED VIEW IF EXISTS reporting.mv_olap_sales_by_lsp;");
            migrationBuilder.Sql("DROP MATERIALIZED VIEW IF EXISTS reporting.mv_olap_sales_by_cost;");
            foreach (var view in new[] { "v_catalogue", "v_tax", "v_cash", "v_claims",
                         "v_prescriptions", "v_wholesale", "v_orders", "v_cost",
                         "v_sales", "v_purchasing", "v_inventory", "v_customer" })
            {
                migrationBuilder.Sql($"DROP VIEW IF EXISTS reporting.{view};");
            }

        }
    }
}
