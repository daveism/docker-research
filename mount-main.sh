#!/bin/bash

# cd /
# ./mount-2000.sh
# ./mount-2001.sh
# ./mount-2002.sh

set -eu

for mnt in "$@"; do
  if [[ ! "$mnt" =~ ^/exports/ ]]; then
    >&2 echo "Path to NFS export must be inside of the \"/exports/\" directory"
    exit 1
  fi
  mkdir -p $mnt
  chmod 777 $mnt
  mhddfs /mnt/2000/,/mnt/2001/,/mnt/2002/ $mnt
  echo "$mnt *(rw,sync,no_subtree_check,no_root_squash,fsid=0)" >> /etc/exports
done

exportfs -a
rpcbind
rpc.statd
rpc.nfsd

# force rebuild
exec rpc.mountd --foreground
