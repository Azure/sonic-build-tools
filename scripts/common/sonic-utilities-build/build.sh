#!/bin/bash -xe

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

cat <<EOF > build_sonic_utilities.sh
#!/bin/bash -xe
ls -lrt

sudo pip3 install --upgrade setuptools
sudo pip3 install buildimage/target/python-wheels/swsssdk-2.0.1-py3-none-any.whl
sudo pip3 install buildimage/target/python-wheels/sonic_py_common-1.0-py3-none-any.whl
sudo pip3 install buildimage/target/python-wheels/sonic_config_engine-1.0-py3-none-any.whl
sudo pip3 install buildimage/target/python-wheels/sonic_platform_common-1.0-py3-none-any.whl
sudo pip3 install buildimage/target/python-wheels/sonic_yang_mgmt-1.0-py3-none-any.whl
sudo pip3 install buildimage/target/python-wheels/sonic_yang_models-1.0-py3-none-any.whl

sudo dpkg -i buildimage/target/debs/buster/libyang_1.0.73_amd64.deb
sudo dpkg -i buildimage/target/debs/buster/libyang-cpp_1.0.73_amd64.deb
sudo dpkg -i buildimage/target/debs/buster/python3-yang_1.0.73_amd64.deb

# Below is required for swsscommon
sudo dpkg -i buildimage/target/debs/buster/{libnl-3-200_*.deb,libnl-genl-3-200_*.deb,libnl-nf-3-200_*.deb,libnl-route-3-200_*.deb,libhiredis0.14_*.deb}
sudo dpkg -i buildimage/target/debs/buster/libswsscommon_1.0.0_amd64.deb
sudo dpkg -i buildimage/target/debs/buster/python3-swsscommon_1.0.0_amd64.deb

cd sonic-utilities

# Run unit tests
sudo python3 setup.py test

# Build the Python wheel
sudo python3 setup.py bdist_wheel

EOF

chmod 755 build_sonic_utilities.sh

# Build sonic-utilities and copy resulting Python wheel
docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-buster-johnar ./build_sonic_utilities.sh

cp sonic-utilities/dist/sonic_utilities-*.whl buildimage/target/python-wheels/

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
    sudo umount docker-sonic-vs/python-wheels
}
trap on_exit EXIT

cd buildimage/platform/vs
mkdir -p docker-sonic-vs/debs
mkdir -p docker-sonic-vs/files
mkdir -p docker-sonic-vs/python-wheels
sudo mount --bind ../../target/debs/buster docker-sonic-vs/debs
sudo mount --bind ../../target/files/buster docker-sonic-vs/files
sudo mount --bind ../../target/python-wheels docker-sonic-vs/python-wheels
docker load < ../../target/docker-config-engine-buster.gz
docker build --no-cache -t docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} docker-sonic-vs
docker save docker-sonic-vs:${JOB_NAME##*/}.${BUILD_NUMBER} | gzip -c > ../../target/docker-sonic-vs.gz
