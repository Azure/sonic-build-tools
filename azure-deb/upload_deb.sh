#!/bin/bash
# Usage:  ./upload_deb.sh -p pass -r repoid -u upload_saskey -d download_saskey packages



function BailIf
{
    if [ $1 -ne 0 ]; then
        echo "Failure occurred communicating with $server"
        exit 1
    fi
}

while getopts "p:u:d:r:" opt; do
  case $opt in
    p)
      pass=$OPTARG
      ;;
    r)
      REPOSITORYID=$OPTARG
      export REPOSITORYID
      ;;
    u)
      upload_saskey=$OPTARG
      ;;
    d)
      download_saskey=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

shift $((OPTIND-1))


for f in $*
do
  echo "Processing $f file..."
  python blobxfer.py sonicstorage packages $f --saskey "${upload_saskey}"
 #BailIf $?
 echo ""
 
 PACKAGENAME="$(dpkg --info $f | grep Package: | awk '{print $2}')"
 PACKAGEVERSION="$(dpkg --info $f | grep Version: | awk '{print $2}')"
 REPOSITORYID=$REPOSITORYID
 PACKAGEURL="https://sonicstorage.blob.core.windows.net/packages/$f?${download_saskey}"

 python new_package.py $PACKAGENAME $PACKAGEVERSION $REPOSITORYID $PACKAGEURL
 BailIf $? 
 echo ""
 cat new_package.json

 ./repoapi_client.sh -p $pass addpkg new_package.json
 BailIf $?
 echo ""
done
