# Schedule a nightly backup

1. Make the script executable:
   `chmod +x /absolute/path/postgresql-daily-backup/scripts/backup.sh`
2. Open the current user's cron table:
   `crontab -e`
3. Add this line, replacing the path with your actual project path:

   `0 2 * * * /absolute/path/postgresql-daily-backup/scripts/backup.sh`

This runs every day at 2:00 AM in the machine's local time zone.

Check the log file at `logs/backup.log`. The cron user must be able to read the
configuration and connect to PostgreSQL. Use absolute paths in the configuration.

List scheduled jobs with `crontab -l`.
