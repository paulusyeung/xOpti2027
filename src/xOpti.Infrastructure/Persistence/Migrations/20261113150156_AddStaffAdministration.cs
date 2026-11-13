using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddStaffAdministration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "display_name",
                table: "asp_net_users",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "default_branch_code",
                table: "asp_net_users",
                type: "character varying(3)",
                maxLength: 3,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "disabled",
                table: "asp_net_users",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            // Security audit is append-only: normal application users cannot
            // rewrite or delete entries, even through a compromised API path.
            migrationBuilder.Sql("""
                CREATE OR REPLACE FUNCTION platform.reject_audit_log_mutation() RETURNS trigger
                LANGUAGE plpgsql AS $$
                BEGIN
                    RAISE EXCEPTION 'platform.audit_log is append-only';
                END;
                $$;
                CREATE TRIGGER audit_log_append_only
                    BEFORE UPDATE OR DELETE ON platform.audit_log
                    FOR EACH ROW EXECUTE FUNCTION platform.reject_audit_log_mutation();
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                DROP TRIGGER IF EXISTS audit_log_append_only ON platform.audit_log;
                DROP FUNCTION IF EXISTS platform.reject_audit_log_mutation();
                """);

            migrationBuilder.DropColumn(
                name: "default_branch_code",
                table: "asp_net_users");

            migrationBuilder.DropColumn(
                name: "disabled",
                table: "asp_net_users");

            migrationBuilder.AlterColumn<string>(
                name: "display_name",
                table: "asp_net_users",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100,
                oldNullable: true);
        }
    }
}
