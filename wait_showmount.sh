#!/bin/bash
# wait-showmount.sh

until showmount -e 10.5.0.3; do
  echo "NFS mount is unavailable - sleeping"
  sleep 1
done

echo "NFS mount is up - executing command"
mount -t nfs -o nolock 10.5.0.3:/exports/data/ /data/
