#!/bin/bash
# RPanel

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <add/del> <username> <max_logins>"
    exit 1
fi

action="$1"
username="$2"
max_logins="$3"

LIMITS_FILE="/etc/security/limits.conf"
BACKUP_FILE="/etc/security/limits.conf.bak.$(date +%Y%m%d%H%M%S)"

if [ ! -f "$LIMITS_FILE" ]; then
    echo "Error: $LIMITS_FILE not found."
    exit 1
fi

cp "$LIMITS_FILE" "$BACKUP_FILE"

if [ "$action" = "add" ]; then
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist. Skipping limit set." >&2
        exit 0
    fi
    if grep -q "^$username[[:space:]]\+hard[[:space:]]\+maxlogins" "$LIMITS_FILE"; then
        # بروزرسانی مقدار maxlogins بصورت inplace
        sed -i "s/^$username[[:space:]]\+hard[[:space:]]\+maxlogins[[:space:]]\+[0-9]\+/$username hard maxlogins $max_logins/" "$LIMITS_FILE"
        echo "User $username limit updated to $max_logins (previous backup: $BACKUP_FILE)"
    else
        echo "$username hard maxlogins $max_logins" >> "$LIMITS_FILE"
        echo "User $username limit set to $max_logins (previous backup: $BACKUP_FILE)"
    fi
elif [ "$action" = "del" ]; then
    if grep -q "^$username[[:space:]]\+hard[[:space:]]\+maxlogins" "$LIMITS_FILE"; then
        sed -i "/^$username[[:space:]]\+hard[[:space:]]\+maxlogins[[:space:]]\+[0-9]\+/d" "$LIMITS_FILE"
        echo "User $username limit removed (previous backup: $BACKUP_FILE)"
    else
        echo "No limit found for $username. (previous backup: $BACKUP_FILE)"
    fi
else
    echo "Unknown action: $action. Please use 'add' or 'del'."
    exit 1
fi
