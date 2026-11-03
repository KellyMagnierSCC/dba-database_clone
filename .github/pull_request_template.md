<!--
Pick the template for your change type by adding it to the address of the pull request page:
  - if the address already contains ?expand=1 (it does when you start from GitHub Desktop), add &template=<file>
  - if the address has no ? in it, add ?template=<file>  (use ?expand=1&template=<file> to skip the extra click)

  template=new_object.md           new table, view or procedure in an existing package
  template=change_object.md        change to an existing view or procedure
  template=table_migration.md      change to an existing table (08_migrations)
  template=new_package.md          new deployment package
  template=third_party_update.md   new release of vendor code (02_third_party)

Examples: https://github.com/SurreyCountyCouncil/dba-database/compare/main...my-branch?expand=1&template=table_migration.md
          (from GitHub Desktop, the address already ends ?expand=1, so just add &template=table_migration.md)
Use this default only for changes that fit none of them (documentation, tooling).
-->

Closes #<!-- issue number -->

## What and why

<!-- What does this change and why is it needed? -->

## Testing

<!-- What did you run, in which test database on which non-production instance, and what was the result? -->

## Deployment record

<!-- Fill in as each server is deployed. Write "n/a" for documentation or tooling changes. -->

| Server | Environment | Deployed by | Date (UTC) | Commit | Result |
|---|---|---|---|---|---|
| | | | | | |

## Rollback

<!-- How would this be undone? -->
