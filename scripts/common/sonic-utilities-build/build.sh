#!/bin/bash -xe

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

cat <<EOF > build_sonic_utilities.sh
#!/bin/bash -xe
ls -lrt

sudo apt-get install python-m2crypto
sudo apt-get -y purge python-click
sudo pip install "click>=7.0"
sudo pip install click-default-group==1.2
sudo pip install tabulate
sudo pip install natsort
sudo pip install buildimage/target/python-wheels/sonic_config_engine-1.0-py2-none-any.whl
sudo pip install buildimage/target/python-wheels/swsssdk-2.0.1-py2-none-any.whl
sudo pip install buildimage/target/python-wheels/sonic_yang_mgmt-1.0-py2-none-any.whl
sudo pip install mockredispy==2.9.3
sudo pip install netifaces==0.10.9
sudo pip install --upgrade setuptools
sudo pip install pytest-runner==4.4
sudo pip install xmltodict==0.12.0
sudo pip install jsondiff==1.2.0

sudo pip3 install buildimage/target/python-wheels/sonic_yang_models-1.0-py3-none-any.whl

sudo dpkg -i buildimage/target/debs/buster/libyang_1.0.73_amd64.deb
sudo dpkg -i buildimage/target/debs/buster/libyang-cpp_1.0.73_amd64.deb
sudo dpkg -i buildimage/target/debs/buster/python2-yang_1.0.73_amd64.deb

cd sonic-utilities

# Test building the Debian package
sudo python setup.py --command-packages=stdeb.command bdist_deb

EOF

chmod 755 build_sonic_utilities.sh

# Build sonic-utilities and copy resulting Debian package
docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar ./build_sonic_utilities.sh

cp sonic-utilities/deb_dist/python-sonic-utilities_*.deb buildimage/target/python-debs/

cd sairedis
cp *.deb ../buildimage/target/debs/buster/
cd ../

cd swss
cp *.deb ../buildimage/target/debs/buster/
cd ../

cd swss-common
cp *.deb ../buildimage/target/debs/buster/
cd ../

on_exit()
{
    sudo umount docker-sonic-vs/debs
    sudo umount docker-sonic-vs/files
    sudo umount docker-sonic-vs/python-debs
    sudo umount docker-sonic-vs/python-wheels
}
trap on_exit EXIT

cd buildimage/platform/vs
mkdir -p docker-sonic-vs/debs
mkdir -p docker-sonic-vs/files
mkdir -p docker-sonic-vs/python-debs
mkdir -p docker-sonic-vs/python-wheels
sudo mount --bind ../../target/debs/buster docker-sonic-vs/debs
sudo mount --bind ../../target/files/buster docker-sonic-vs/files
sudo mount --bind ../../target/python-debs docker-sonic-vs/python-debs
sudo mount --bind ../../target/python-wheels docker-sonic-vs/python-wheels
docker load < ../../target/docker-config-engine-buster.gz
docker build --no-cache -t docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} docker-sonic-vs
docker save docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} | gzip -c > ../../target/docker-sonic-vs.gz
