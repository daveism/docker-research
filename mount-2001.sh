until showmount -e 10.5.0.201; do
  echo "NFS mount is unavailable - sleeping"
  sleep 1
done

echo "NFS mount is up - executing command"
mount -t nfs -o nolock 10.5.0.201:/exports/data/ /mnt/2001
# ln -s /mnt/2001/* /exports/data
