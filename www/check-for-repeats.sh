#hopefully this will let us know if we ever have repeated basenames of assets
#they are only saved as their basename in the device

#you must provide a filename for this to work to avoid issues with relative paths
cat $1 | xargs -I {} basename {} | sort | uniq -d | diff - /dev/null

#if you need to repeat a name, this whole scheme needs rethinking
