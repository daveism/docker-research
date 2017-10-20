until showmount -e 10.5.0.200; do
  echo "NFS mount is unavailable - sleeping"
  sleep 1
done

echo "NFS mount is up - executing command"
mount -t nfs -o nolock 10.5.0.200:/exports/data/ /mnt/2000
# ln -s /mnt/2002/* /exports/data
