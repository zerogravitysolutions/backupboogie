#!/bin/bash

#
#  BackupBoogie - Bash File Backup Tool
#  Version 1.0
#
#  Author: Qëndrim Pllana
#  GitHub: https://github.com/qenndrimm
#
#  This Bash script is a simple yet powerful tool designed to backup files
#  from a source directory to a backup directory. It efficiently handles file
#  updates and maintains a log of backup operations for monitoring and
#  troubleshooting purposes.
#
#  GitHub Repository: https://github.com/zerogravitysolutions/backupboogie
#

# Create log directory if it doesn't exist
mkdir -p log

# Default number of processes
DEFAULT_NUM_PROCESSES=20

# Configuration
LOG_FILE="log/backup.log"

# Function to log messages
log() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Function to backup a single file
backup_file() {
    local file="$1"
    local backup_dir="$2"
    local backup_datetime="$3"
    local relative_path="${file#$SRC_DIR/}"
    local destination="$backup_dir/$relative_path"

    # Check if source file exists
    if [[ ! -e "$file" ]]; then
        log "Error: Source file '$file' does not exist."
        return 1
    fi

    # Check if backup directory exists
    if [[ ! -d "$backup_dir" ]]; then
        log "Error: Backup directory '$backup_dir' does not exist."
        return 1
    fi

    # Attempt to create destination directory
    mkdir -p "$(dirname "$destination")" || { log "Error: Failed to create directory '$(dirname "$destination")'."; return 1; }

    if [[ ! -e "$destination" ]]; then
        # File doesn't exist in backup, copy the original file to the backup directory
        cp "$file" "$destination" || { log "Error: Failed to copy '$file' to '$destination'."; return 1; }
        log "Copied $relative_path to backup directory."
    else
        # File exists in backup directory
        # Check if file has been updated
        if [[ "$file" -nt "$destination" ]]; then
            # File has been updated, move existing file to backup folder
            mkdir -p "$backup_dir/backup_$backup_datetime/$(dirname "$relative_path")" || { log "Error: Failed to create backup directory '$backup_dir/backup_$backup_datetime/$(dirname "$relative_path")'."; return 1; }
            mv "$destination" "$backup_dir/backup_$backup_datetime/$relative_path" || { log "Error: Failed to move existing file '$destination' to backup folder."; return 1; }
            # Copy the updated file to the original path in the backup directory
            cp "$file" "$destination" || { log "Error: Failed to copy updated file to '$destination'."; return 1; }
            log "Updated $relative_path. Moved old version to backup folder."
        fi
    fi
}

# Function to backup files
backup_files() {
    local src_dir="$1"
    local backup_dir="$2"
    local backup_datetime=$(date +"%Y-%m-%d_%H")
    local num_processes=0

    # Check if source directory exists
    if [[ ! -d "$src_dir" ]]; then
        log "Error: Source directory '$src_dir' does not exist."
        return 1
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir" || { log "Error: Failed to create backup directory '$backup_dir'."; return 1; }

    # Find all files in the source directory and its subdirectories
    while IFS= read -r -d '' file; do
        # Run backup_file function in background
        backup_file "$file" "$backup_dir" "$backup_datetime" & ((num_processes++))

        # Limit the number of concurrent processes
        if ((num_processes >= DEFAULT_NUM_PROCESSES)); then
            wait  # Wait for background processes to finish before spawning new ones
            num_processes=0
        fi
    done < <(find "$src_dir" -type f -print0)

    wait  # Wait for any remaining background processes to finish
}

# Main
# Check if the script has at least two arguments
if [[ $# -lt 2 ]]; then
    log "Error: Usage: $0 -s <SRC_DIR> -t <TARGET_DIR> [-k <SSH_KEY>] [-p NUM_PROCESSES]"
    exit 1
fi

# Parse command-line options
# Extracting SRC_DIR, BACKUP_DIR, REMOTE_DIR, REMOTE_HOST, REMOTE_USER, SSH_KEY, and NUM_PROCESSES from arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            shift
            NUM_PROCESSES=$1
            ;;
        -s)
            shift
            SRC_DIR=$1
            ;;
        -t)
            shift
            TARGET=$1
            ;;
        -k)
            shift
            SSH_KEY=$1
            ;;
    esac
    shift
done

# Parse target for remote directory or local directory
if [[ $TARGET == *":"* ]]; then
    REMOTE_USER=$(echo "$TARGET" | cut -d":" -f1)
    REMOTE_HOST=$(echo "$TARGET" | cut -d":" -f2 | cut -d"/" -f1)
    REMOTE_DIR=$(echo "$TARGET" | cut -d":" -f2 | cut -d"/" -f2-)
    # Check if the target format is correct
    if [[ -z "$REMOTE_USER" || -z "$REMOTE_HOST" || -z "$REMOTE_DIR" ]]; then
        log "Error: Incorrect target format. Please provide the target in the format 'user@host:/path/to/directory'."
        exit 1
    fi
else
    BACKUP_DIR=$TARGET
fi

# If an SSH key is provided, construct the SSH command with the specified key
if [[ -n "$SSH_KEY" ]]; then
    SSH_COMMAND="ssh -i $SSH_KEY $REMOTE_USER@$REMOTE_HOST"
else
    SSH_COMMAND="ssh $REMOTE_USER@$REMOTE_HOST"
fi

# Example usage of SSH command
if [[ -n "$REMOTE_DIR" ]]; then
    $SSH_COMMAND mkdir -p "$REMOTE_DIR"
else
    mkdir -p "$BACKUP_DIR"
fi

# Set default number of processes if not specified
NUM_PROCESSES=${NUM_PROCESSES:-$DEFAULT_NUM_PROCESSES}

# Perform backup and log the operation
echo -e "\n" >>  "$LOG_FILE" # add empty lines
log "Starting backup process from $SRC_DIR to $BACKUP_DIR with $NUM_PROCESSES processes..."
backup_files "$SRC_DIR" "$BACKUP_DIR"
log "Backup process completed."