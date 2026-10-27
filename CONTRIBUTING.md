# Contributing to the DBA database

This repository is the source of truth for the DBA utility database. The live databases are deployed from it, and nothing in them should exist only on a server. This page covers what to set up before your first change. The day-to-day process is in [docs/how-to/00_github-workflow.md](docs/how-to/00_github-workflow.md).

## The rules that matter most

1. **Every change goes through an issue and a reviewed pull request.** Nobody pushes to `main`, and nobody changes objects directly on a server. If an emergency forces a server change, bring it back into the repo the same day (see the workflow guide).
2. **Test your branch in your own database; release only from `main`.** While you work, deploy your branch into a database of your own (for example `DBA_<yourname>`) on a non-production instance. Shared databases, including the team's `DBA` database on the dev server, and every production server are deployed only from an up-to-date `main`.
3. **Never hand-edit generated files**, meaning everything in `09_deployment/` except `config.sql` and `local_deploy.example.sql`, plus `10_metadata/apply_extended_properties.sql` and `tools/find_old_name_references.sql`. Change the CSVs in `10_metadata/` and run the generator.
4. **Never edit vendor code** in `02_third_party/`. Only replace it with a new release.
5. **An existing table only changes through a migration** in `08_migrations/`, together with the matching change to its file in `04_tables/`.
6. **Object files contain no `USE` and no database name.** The database is chosen at deploy time.

## One-off setup

### 1. Access

- A GitHub account in the **SurreyCountyCouncil** organisation, and membership of the **DevOps Team**. The team has write access, and its members review each other's pull requests.
- Access to a **non-production** SQL Server instance with a copy of the DBA database to test against.

### 2. Tools

| Tool | Why |
|---|---|
| **Git for Windows** | Cloning, branching, committing |
| **SQL Server Management Studio**, used in **SQLCMD Mode** (Query → SQLCMD Mode) | Running the deploy scripts. Alternatively, `sqlcmd.exe` from the command line |
| **Windows PowerShell 5.1** or **PowerShell 7** | Running `tools\generate_deploy.ps1` |
| A text editor that keeps line endings and encoding, e.g. VS Code | Editing `.sql`, `.csv` and `.md` files. `.gitattributes` sets the line endings |

Tell Git who you are, once:

```
git config --global user.name  "Your Name"
git config --global user.email "your.name@surreycc.gov.uk"
```

### 3. Clone to a path without spaces

```
cd D:\DevOps
git clone https://github.com/SurreyCountyCouncil/dba-database.git
```

The deploy scripts build their file paths from your clone's location, and those paths can't contain spaces. `D:\DevOps\dba-database` is fine. `C:\Users\Your Name\Documents\dba-database` is not.

### 4. Check the generator runs

From the repository root, in PowerShell:

```powershell
.\tools\generate_deploy.ps1
git status
```

It should finish with a "Generated ..." line, and `git status` should show no changes.

If PowerShell refuses to run the script because "running scripts is disabled on this system", allow scripts for your own account:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

If your machine's policy doesn't allow that, run it as `powershell -ExecutionPolicy Bypass -File .\tools\generate_deploy.ps1`.

### 5. Set up your personal deploy file (SSMS)

```
copy 09_deployment\local_deploy.example.sql 09_deployment\local_deploy.sql
```

Edit `local_deploy.sql`:

- set `RepoRoot` to your clone, e.g. `D:\DevOps\dba-database`;
- set `DatabaseName` to the database on the server you're deploying to;
- uncomment the one deploy script you want to run.

Git ignores this file, so your values are never committed. Open it in SSMS, connect to the target server, turn on **SQLCMD Mode** and run it. The first line of the output says which server and database it is deploying to. Check that line every time.

For `sqlcmd.exe`, use the commands in the README's **Deploying** section.

## Making your first change

1. Read [00_github-workflow.md](docs/how-to/00_github-workflow.md) for the issue → branch → pull request → deploy process.
2. Then read the guide for what you're changing:
   - a new object in an existing package: [02_adding-objects-to-a-package.md](docs/how-to/02_adding-objects-to-a-package.md), starting from a template in `tools/templates/`;
   - a change to a view, procedure or table: [03_changing-existing-objects-and-migrations.md](docs/how-to/03_changing-existing-objects-and-migrations.md);
   - a new package: [01_adding-a-new-package.md](docs/how-to/01_adding-a-new-package.md).
3. Check names against `docs/naming-conventions.pdf` and the "Known deviations" section of the [README](README.md), which includes the `usp_Alert_` prefix.

A good first change is a small one, such as a view fix. It takes you through every step of the process without much risk.

## Getting help

Ask in the issue or pull request you're working on, so the answer stays with the change. For something that isn't tied to a change, open a blank issue.
