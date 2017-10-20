until showmount -e 10.5.0.202; do
  echo "NFS mount is unavailable - sleeping"
  sleep 1
done

echo "NFS mount is up - executing command"
mount -t nfs -o nolock 10.5.0.202:/exports/data/ /mnt/2002
# ln -s /mnt/2002/* /exports/data
