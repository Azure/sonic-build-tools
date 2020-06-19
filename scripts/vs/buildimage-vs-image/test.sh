#!/bin/bash -x

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

ls -l

tbname=vms-kvm-t0
dut=vlab-01

docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker pull sonicdev-microsoft.azurecr.io:443/docker-sonic-mgmt:latest

cat $PRIVATE_KEY > pkey.txt

mkdir -p $HOME/sonic-vm/images
if [ -e target/sonic-vs.img.gz ]; then
    cp target/sonic-vs.img.gz $HOME/sonic-vm/images/
else
    sudo cp /nfs/jenkins/sonic-vs-${JOB_NAME##*/}.${BUILD_NUMBER}.img.gz $HOME/sonic-vm/images/sonic-vs.img.gz
fi
gzip -fd $HOME/sonic-vm/images/sonic-vs.img.gz

ls -l $HOME/sonic-vm/images

cd sonic-mgmt/ansible
sed -i s:use_own_value:johnar: veos.vtb
echo abc > password.txt
cd ../../
docker run --rm=true -v $(pwd):/data -w /data -i sonicdev-microsoft.azurecr.io:443/docker-sonic-mgmt ./scripts/vs/buildimage-vs-image/runtest.sh $tbname

# save dut state if test fails
if [ $? != 0 ]; then
    virsh_version=$(virsh --version)
    if [ $virsh_version == "6.0.0" ]; then
        rm -rf kvmdump
        mkdir -p kvmdump
        virsh save $dut kvmdump/$dut.memdmp
        virsh dumpxml $dut > kvmdump/$dut.xml
        img=$(virsh domblklist $dut | grep vda | awk '{print $2}')
        cp $img kvmdump/$dut.img
        virsh undefine $dut
    fi
    exit 2
fi
