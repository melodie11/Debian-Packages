#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# =================================================================
#                         Root check
# =================================================================

[ "$(id -u)" -ne 0 ] && { echo "This script must be run as root." >&2; exit 1; }


# =================================================================
#          Cleaning functions before remastering
# =================================================================

# Function to delete files or directories matching a pattern
cleanup_by_pattern() {
    local search_pattern="$1"
    local search_path="$2"
    local tmp_file
    tmp_file=$(mktemp)
    trap 'rm -f "$tmp_file"' EXIT

    echo "Searching for '${search_pattern}' in '${search_path}'..."

    find "${search_path}" \( -path /proc -o -path /sys -o -path /dev -o -path /tmp \) -prune -o \
        -name "${search_pattern}" -print > "$tmp_file" 2>/dev/null

    local files_found
    files_found=$(wc -l < "$tmp_file")

    if [ "$files_found" -eq 0 ]; then
        echo "No '${search_pattern}' elements found."
        return 1
    fi

    echo "--- $files_found elements found. List: ---"
    cat "$tmp_file"

    read -p "Do you really want to delete these elements? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting elements..."
        while read -r item; do
            if [ -f "$item" ]; then
                if rm "$item"; then
                    echo "Deleted (file): $item"
                else
                    echo "ERROR: cannot delete $item" >&2
                fi
            elif [ -d "$item" ]; then
                if rm -r "$item"; then
                    echo "Deleted (directory): $item"
                else
                    echo "ERROR: cannot delete $item" >&2
                fi
            fi
        done < "$tmp_file"
        echo "Cleanup complete for '${search_pattern}'."
    else
        echo "Deletion cancelled. No elements were modified."
    fi

    return 0
}

# Function to delete files in specific directories
cleanup_files_in_dirs() {
    local dirs=("$@")
    local tmp_file
    tmp_file=$(mktemp)
    trap 'rm -f "$tmp_file"' EXIT

    echo "Searching for unnecessary files in specified directories..."

    for dir in "${dirs[@]}"; do
        echo "--- Processing directory ${dir} ---"
        find "$dir" -type f > "$tmp_file" 2>/dev/null
        local files_found
        files_found=$(wc -l < "$tmp_file")

        if [ "$files_found" -eq 0 ]; then
            echo "No files to delete in ${dir}."
            continue
        fi

        echo "$files_found files found. List:"
        cat "$tmp_file"

        read -p "Do you really want to delete these files? (y/n) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting files..."
            while read -r file; do
                if [ -f "$file" ]; then
                    if rm "$file"; then
                        echo "Deleted: $file"
                    else
                        echo "ERROR: cannot delete $file" >&2
                    fi
                fi
            done < "$tmp_file"
            echo "Cleanup complete for ${dir}."
        else
            echo "Deletion cancelled."
        fi
    done
}


# =================================================================
#                        Script execution
# =================================================================

# 1. Clean root user command history
echo "--- Cleaning root user command history ---"
> /root/.bash_history
echo "/root/.bash_history cleared."

echo "========================================="

# 1b. Clean root user trace files
echo "--- Cleaning root trace files ---"
for f in \
    /root/.local/share/recently-used.xbel \
    /root/.local/share/mc/filepos \
    /root/.local/share/mc/history; do
    if [ -f "$f" ]; then
        > "$f"
        echo "Cleared: $f"
    fi
done

echo "========================================="

# 2. Clean cached packages with apt
echo "Cleaning cached packages with 'apt clean'..."
read -p "Do you want to run APT cleanup? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    apt clean
    rm -f /var/cache/apt/{pkgcache.bin,srcpkgcache.bin}
    echo "APT cleanup complete."
else
    echo "APT cleanup cancelled."
fi

# 2b. Purge residual packages (rc)
RESIDUALS=$(dpkg -l | awk '/^rc/ {print $2}')

if [ -n "$RESIDUALS" ]; then
    echo "Residual packages detected:"
    echo "$RESIDUALS"
    read -p "Do you want to purge them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apt purge $RESIDUALS
        echo "Residual packages purged."
    else
        echo "Purge cancelled."
    fi
else
    echo "No residual packages detected."
fi

echo "========================================="

# 3. Clean files in specific directories
dirs_to_clean=(
    "/var/log"
    "/var/backups"
    "/var/lib/apt/lists"
    "/var/cache/system-tools-backends/backup/"
)

cleanup_files_in_dirs "${dirs_to_clean[@]}"

echo "========================================="

# 4. Clean *.bak, *.old, *.dpkg-dist and *.dpkg-old files
cleanup_by_pattern "*.bak" "/"
cleanup_by_pattern "*.old" "/"
cleanup_by_pattern "*.dpkg-dist" "/"
cleanup_by_pattern "*.dpkg-old" "/"

echo "========================================="

# 5. Reminder for manual check
echo "REMINDER: Don't forget to manually check the number of installed Linux kernels."
echo "To do so, check the contents of the /boot directory.
"

