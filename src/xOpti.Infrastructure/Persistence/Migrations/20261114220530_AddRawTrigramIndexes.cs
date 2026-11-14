using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace xOpti.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddRawTrigramIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                CREATE INDEX IF NOT EXISTS ix_inventory_name_trgm_raw
                    ON public.inventory USING gin (name gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_supplier_name_trgm_raw
                    ON public.supplier USING gin (supplier_name gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_doctor_name_trgm_raw
                    ON public.doctor USING gin (doctor_name gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_staff_fullname_trgm_raw
                    ON public.staff USING gin (staff_full_name gin_trgm_ops);
                CREATE INDEX IF NOT EXISTS ix_branch_name_trgm_raw
                    ON public.branch USING gin (branch_name gin_trgm_ops);
                """);


        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                DROP INDEX IF EXISTS public.ix_inventory_name_trgm_raw;
                DROP INDEX IF EXISTS public.ix_supplier_name_trgm_raw;
                DROP INDEX IF EXISTS public.ix_doctor_name_trgm_raw;
                DROP INDEX IF EXISTS public.ix_staff_fullname_trgm_raw;
                DROP INDEX IF EXISTS public.ix_branch_name_trgm_raw;
                """);


        }
    }
}
