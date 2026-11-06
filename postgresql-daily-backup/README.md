# PostgreSQL Daily Automated Backup

## Aim
Create a scheduled Bash script that backs up a PostgreSQL database every day, stores
date-stamped backup files, and documents how to restore a backup.

## Requirements
- Linux or WSL
- PostgreSQL client utilities: pg_dump, pg_restore, createdb, psql
- Bash and cron

## Setup
1. Copy `config/backup.conf.example` to `config/backup.conf`.
2. Edit the database and directory settings.
3. Make the script executable: `chmod +x scripts/backup.sh`
4. Run a manual test: `./scripts/backup.sh`
5. Schedule it using the instructions in `docs/cron_setup.md`.

The script creates a PostgreSQL custom-format dump (`.dump`). This format is already
compressed by PostgreSQL, so it is not piped through gzip. Restore it with pg_restore.

## Restore
Follow `docs/restore.md` and restore into a separate test database, never over production.

## Security
Use a dedicated backup account. Prefer `~/.pgpass` with permission 600 for passwords.
Protect `config/backup.conf` with `chmod 600 config/backup.conf`.
