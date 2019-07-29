#!/bin/bash -xe

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

cat <<EOF > build_sonic_utilities.sh
#!/bin/bash -xe
ls -lrt

sudo pip install click
sudo pip install click-default-group
sudo pip install tabulate
sudo pip install natsort
sudo pip install buildimage/target/python-wheels/sonic_config_engine-1.0-py2-none-any.whl
sudo pip install buildimage/target/python-wheels/swsssdk-2.0.1-py2-none-any.whl
sudo pip install mockredispy==2.9.3
sudo pip install netifaces==0.10.9
sudo pip install --upgrade setuptools
sudo pip install pytest-runner==4.4

cd sonic-utilities

# Test building the Debian package
sudo python setup.py --command-packages=stdeb.command bdist_deb

EOF

chmod 755 build_sonic_utilities.sh

# Build sonic-utilities and copy resulting Debian package
docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-stretch:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-stretch:latest ./build_sonic_utilities.sh

cp sonic-utilities/deb_dist/python-sonic-utilities_*.deb buildimage/target/python-debs/

cd sairedis
cp *.deb ../buildimage/target/debs/stretch/
cd ../

cd swss
cp *.deb ../buildimage/target/debs/stretch/
cd ../

cd swss-common
cp *.deb ../buildimage/target/debs/stretch/
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
sudo mount --bind ../../target/debs/stretch docker-sonic-vs/debs
sudo mount --bind ../../target/files/stretch docker-sonic-vs/files
sudo mount --bind ../../target/python-debs docker-sonic-vs/python-debs
sudo mount --bind ../../target/python-wheels docker-sonic-vs/python-wheels
docker load < ../../target/docker-config-engine-stretch.gz
docker build --squash --no-cache -t docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} docker-sonic-vs
docker save docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} | gzip -c > ../../target/docker-sonic-vs.gz
