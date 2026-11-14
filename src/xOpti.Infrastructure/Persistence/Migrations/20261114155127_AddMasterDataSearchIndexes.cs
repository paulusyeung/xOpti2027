using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddMasterDataSearchIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                CREATE EXTENSION IF NOT EXISTS pg_trgm;
                CREATE INDEX IF NOT EXISTS ix_inventory_name_trgm
                    ON public.inventory USING gin (lower(name) gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_supplier_name_trgm
                    ON public.supplier USING gin (lower(supplier_name) gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_doctor_name_trgm
                    ON public.doctor USING gin (lower(doctor_name) gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_staff_fullname_trgm
                    ON public.staff USING gin (lower(staff_full_name) gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_branch_name_trgm
                    ON public.branch USING gin (lower(branch_name) gin_trgm_ops);
                """);

        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                DROP INDEX IF EXISTS public.ix_inventory_name_trgm;
                DROP INDEX IF EXISTS public.ix_supplier_name_trgm;
                DROP INDEX IF EXISTS public.ix_doctor_name_trgm;
                DROP INDEX IF EXISTS public.ix_staff_fullname_trgm;
                DROP INDEX IF EXISTS public.ix_branch_name_trgm;
                """);

        }
    }
}
