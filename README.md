
# Linux Backup and Disaster Recovery Lab

## Project Overview

This project demonstrates how to automate Linux file backups and recover data after accidental loss using Bash scripting.

The system creates compressed backups, verifies backup integrity using SHA-256 checksums, maintains timestamped logs, and supports file restoration.

It also uses cron to schedule automatic daily backups.

## Project Objectives

- Automate Linux file backups using Bash.
- Compress backup archives using tar and gzip.
- Verify backup integrity using SHA-256.
- Maintain timestamped backup logs.
- Remove expired backups using a retention policy.
- Restore files after simulated data loss.
- Schedule automated backups using cron.

## Technologies Used

- Ubuntu Linux (WSL)
- Bash
- tar and gzip
- SHA-256
- cron
- Git and GitHub

## Project Structure

```text
linux-backup-disaster-recovery-lab/
├── backups/
├── config/
│   └── backup.conf
├── docs/
├── logs/
├── sample-data/
│   └── app/
├── scripts/
│   ├── backup.sh
│   └── restore.sh
├── tests/
└── .gitignore
```

## Features

### Automated Backups

The `backup.sh` script:

1. Loads backup configuration.
2. Checks that the source directory exists.
3. Creates a timestamped compressed archive.
4. Validates the archive.
5. Generates a SHA-256 checksum.
6. Removes expired backups according to the retention policy.
7. Records operations in a log file.

### Disaster Recovery

The `restore.sh` script:

1. Checks that the backup archive exists.
2. Verifies its SHA-256 checksum.
3. Validates the compressed archive.
4. Prevents overwriting an existing restore destination.
5. Extracts the backup into a temporary directory.
6. Publishes the restored files after successful extraction.

### Automated Scheduling

Cron is configured to execute the backup script daily at 2:30 AM.

```cron
30 2 * * * /bin/bash /home/mutiat/projects/linux-backup-disaster-recovery-lab/scripts/backup.sh >> /home/mutiat/projects/linux-backup-disaster-recovery-lab/logs/cron.log 2>&1
```

## How to Run

Clone the repository:

```bash
git clone <YOUR-GITHUB-REPOSITORY-URL>
cd linux-backup-disaster-recovery-lab
```

Run the backup:

```bash
./scripts/backup.sh
```

List available backups:

```bash
ls -lh backups/
```

Restore a backup:

```bash
./scripts/restore.sh backups/backup_TIMESTAMP.tar.gz restored-data
```

Replace `backup_TIMESTAMP.tar.gz` with the actual backup filename.

## Testing and Validation

The project was tested by:

- Creating compressed backup archives.
- Verifying SHA-256 checksums.
- Checking archive integrity.
- Simulating accidental loss of the source directory.
- Restoring files from a backup.
- Comparing recovered files with the original data using `diff -r`.
- Verifying automated backup execution through cron logs.

## Learning Outcomes

This project provided practical experience with:

- Linux system administration.
- Bash scripting and automation.
- Linux file permissions.
- Backup and recovery procedures.
- Data integrity verification.
- Cron scheduling.
- Git version control.

## Future Improvements

- Upload backups to AWS S3.
- Add email notifications for backup failures.
- Improve automated test coverage.
- Add backup encryption.
- Implement remote backup storage.

## Author

DevOps Portfolio Project
