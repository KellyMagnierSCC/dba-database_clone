# Object templates

Starting points for new objects. Copy a template to the right folder, rename the file to the object name, replace the placeholder name, and add your code. Each template's header lists the rules and the manifest row to add, and you delete the header once you're done.

| Template | Copy to | Placeholder to replace |
|---|---|---|
| `table.sql` | `04_tables/<domain>/<TableName>.sql` | `Domain_Thing_History` |
| `view.sql` | `05_views/<domain>/<ViewName>.sql` | `vw_Domain_Description` |
| `procedure.sql` | `06_programmability/procedures/<domain>/<ProcName>.sql` | `usp_Domain_VerbNoun` |
| `migration.sql` | `08_migrations/YYYYMMDD_NN_<ObjectName>_<Change>.sql` | `Domain_Thing_History`, `NewColumn` |
| `reference_data.sql` | `11_reference_data/<domain>/<TableName>.sql` | `Domain_Thing_Lookup` |

Use find-and-replace on the placeholder, because it also appears in constraint names (`PK_`, `DF_`) and in the manifest row.

Copying a template doesn't deploy anything. A new table, view or procedure must also be added to `10_metadata/object_manifest.csv`, and then you run `.\tools\generate_deploy.ps1`. Migrations go in `10_metadata/migration_manifest.csv` instead, and you run the same generator. Reference data goes in `10_metadata/reference_data_manifest.csv`.

These files are never deployed, because the generator only includes files listed in the manifest.

For the full steps, see `docs/how-to/02_adding-objects-to-a-package.md` (new objects), `docs/how-to/03_changing-existing-objects-and-migrations.md` (migrations) and `docs/how-to/04_reference-data.md` (reference data).
