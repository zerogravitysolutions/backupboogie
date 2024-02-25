# backupboogie
This Bash script is a simple yet powerful tool designed to backup files from a source directory to a backup directory. It efficiently handles file updates and maintains a log of backup operations for monitoring and troubleshooting purposes.

## Features

- **Automatic Backup**: Quickly backs up files from a specified source directory to a backup directory.
- **File Update Detection**: BackupBoogie efficiently detects changes in files and updates the backup accordingly. When running a backup, the tool compares the modification times of files in the source directory with their corresponding files in the backup directory. If a file has been modified since the last backup, BackupBoogie moves the older version of the file to a backup folder and replaces it with the updated version. This ensures that the backup reflects the latest changes in the source files while retaining a history of previous versions.
- **Concurrency Control**: Supports concurrent backup processes for improved performance.
- **Logging**: Logs backup operations to a specified log file for tracking and monitoring.

## Requirements

- **Bash**: The script requires a Bash-compatible environment to run.
- **Linux/Unix**: Primarily tested on Linux and Unix-based systems.

## Usage

1. Clone the repository or download the `run.sh` file.
2. Make the script executable: `chmod +x run.sh`.
3. Run the script with the following command:

```bash
./run.sh -s <SRC_DIR> -t <BACKUP_DIR> [-p NUM_PROCESSES]
```

- `-s <SRC_DIR>`: Specifies the source directory from which files will be backed up.
- `-t <BACKUP_DIR>`: Specifies the directory where backup files will be stored.
- `-p NUM_PROCESSES` (Optional): Specifies the number of concurrent processes to use for the backup operation. If not provided, the default value of 20 processes is used.