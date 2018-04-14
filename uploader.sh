target=$1

#settings
oc_url="https://ubuntu-server/owncloud/remote.php/webdav"
file_size=1MB


jobid=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32)
echo $jobid

mnt_point="/tmp/uploader/mnt/oc_dav"
local_workdir="/tmp/uploader/$jobid"
upload_dir="$mnt_point/uploader/$jobid"


mkdir -p $local_workdir

#create mount directory and connect to webdav
echo ---------- mounting webdav to $mnt_point
mkdir -p $mnt_point
mount -t davfs $oc_url $mnt_point
mkdir -p $upload_dir

#create archive and split
echo ---------- creating ans spliting archive
cd $local_workdir
echo "tar cvzf - $target | split --bytes=$file_size - $jobid.tar.gz."
tar cvzf - $target | split --bytes=$file_size - $jobid.tar.gz.

#copy files
echo ---------- copying files to webdav
cp -rv $local_workdir/* $upload_dir

#unsplit and extract
echo ---------- extracting data
cd $upload_dir
cat $jobid.tar.gz.* | tar zxf -


#cleaning up
echo cleaning up $upload_dir
rm $jobid*
umount $mnt_point
echo cleaning up $local_workdir
cd $local_workdir
rm $jobid*



