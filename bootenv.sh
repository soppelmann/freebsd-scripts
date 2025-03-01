#!/usr/local/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <boot_env>"
  exit 1
fi

subdirectory="$1"
mount_point="/mnt/$subdirectory"
new_be="$subdirectory" #use the subdirectory name for the be

# Sync sources
cd /usr
rsync --exclude .git/ --exclude src/.git/ -avz df:/usr/src .
cd /usr/obj/usr
rsync -avz df:/usr/obj/usr/src ./src/

cd /usr/src
# Create the new boot environment
sudo bectl create "$new_be"

# Mount the new boot environment
sudo bectl mount "$new_be" "$mount_point"

# Install kernel and world, deleting old files
sudo make DESTDIR="$mount_point" BATCH_DELETE_OLD_FILES=yes installkernel delete-old

#sudo make DESTDIR="$mount_point" BATCH_DELETE_OLD_FILES=yes installkernel installworld delete-old

# Update configs in the new boot environment
#etcupdate -D "$mount_point"

# Unmount the new boot environment
sudo bectl umount "$new_be"

# Activate the new boot environment for the next boot
sudo bectl activate -t "$new_be"

echo "Boot environment '$new_be' created, mounted, updated, and activated for next boot."
