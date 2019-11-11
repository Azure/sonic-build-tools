#!/bin/bash -xe

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

ls -l

cat $PRIVATE_KEY > pkey.txt

gzip -d target/sonic-vs.img.gz
mkdir -p $HOME/sonic-vm/images
mv target/sonic-vs.img $HOME/sonic-vm/images/

ls -l $HOME/sonic-vm/images

cd sonic-mgmt/ansible
sed -i s:use_own_value:johnar: veos.vtb
touch password.txt
cd ../../
docker run --rm=true -v $(pwd):/data -w /data -i docker-sonic-mgmt ./scripts/vs/buildimage-vs-image/runtest.sh
