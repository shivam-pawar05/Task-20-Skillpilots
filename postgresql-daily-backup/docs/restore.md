# Restore test on a fresh database

The backup script creates a PostgreSQL custom-format `.dump` file. Restore it using
`pg_restore`, not `gunzip`.

1. Create a separate, empty test database:
   `createdb -h localhost -p 5432 -U your_backup_user backup_restore_test`
2. Restore a selected backup:
   `pg_restore -h localhost -p 5432 -U your_backup_user --no-owner --no-acl -d backup_restore_test /path/to/backup_file.dump`
3. List restored tables:
   `psql -h localhost -p 5432 -U your_backup_user -d backup_restore_test -c "\dt"`
4. Record the restore date, backup filename, and success/failure.

Use a disposable test database. Never test a restore over the production database.
For password authentication, use PostgreSQL's `.pgpass` file with permissions 600;
do not place passwords directly in scripts or command-line arguments.
