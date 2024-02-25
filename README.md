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
./run.sh -s <SRC_DIR> -t <TARGET_DIR> [-k <SSH_KEY>] [-p NUM_PROCESSES]
```

- `-s <SRC_DIR>`: Specifies the source directory from which files will be backed up.
- `-t <TARGET_DIR>`: Specifies the target directory for storing backup files. It can be either a local directory path or a remote directory specified in the format 'user@host:/path/to/directory'.
- `-k <SSH_KEY>` (Optional): Specifies the path to the SSH private key file for SSH key-based authentication. If not provided and the target is a remote directory, the script will prompt for a password at runtime.
- `-p NUM_PROCESSES` (Optional): Specifies the number of concurrent processes to use for the backup operation. If not provided, the default value of 20 processes is used.

### Example Usage

#### Local Directory

To specify a local directory as the target and set the number of concurrent processes using the `-p` option, simply provide the local directory path using the `-t` option and specify the number of processes using the `-p` option. For example:

```bash
./run.sh -s /local/source/directory -t /local/backup/directory -p 5
```

This command will back up files from the local source directory to the local backup directory with 5 concurrent processes. Adjust the number of processes according to your system's capabilities and requirements.

#### Remote Target with SSH Key

To specify a remote directory with SSH key-based authentication, use the `-t` and `-k` options. For example:

```bash
./run.sh -s /local/source/directory -t user@example.com:/remote/backup/directory -k /path/to/your/private/key/id_rsa
```

This command will back up files from the local source directory to the remote backup directory on the server `example.com`, using the specified SSH private key for authentication.

#### Remote Target without SSH Key

If an SSH key is not provided, the script will prompt for a password at runtime. For example:

```bash
./run.sh -s /local/source/directory -t user@example.com:/remote/backup/directory
```