#!/bin/bash

SERVER="futing@211.82.70.102"
REMOTE_DIR="/cluster2/home/futing/Project/panCancer/new"
LOCAL_DIR="/path/to/local/"

if [ ! -f "upload.txt" ]; then
    echo "Error: upload.txt not found!"
    exit 1
fi

while IFS= read -r file; do
    if [ -e "$file" ]; then
        echo "Syncing: $file"
        rsync -avz --progress "$file" "$SERVER:$REMOTE_DIR"
    else
        echo "File not found: $file"
    fi
done < "upload.txt"

echo "Sync completed!"