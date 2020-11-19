#!/bin/bash -xe

echo ${JOB_NAME##*/}.${BUILD_NUMBER}

cat <<EOF > build_sonic_utilities.sh
#!/bin/bash -xe
ls -lrt

sudo apt-get install python-m2crypto
sudo apt-get -y purge python-click
sudo pip install --upgrade setuptools
sudo pip install "click>=7.0"
sudo pip install click-default-group==1.2
sudo pip install tabulate
sudo pip install natsort
sudo pip install buildimage/target/python-wheels/swsssdk-2.0.1-py2-none-any.whl
sudo pip install buildimage/target/python-wheels/sonic_py_common-1.0-py2-none-any.whl
sudo pip install buildimage/target/python-wheels/sonic_config_engine-1.0-py2-none-any.whl
sudo pip install mockredispy==2.9.3
sudo pip install netifaces==0.10.9
sudo pip install pytest-runner==4.4
sudo pip install xmltodict==0.12.0
sudo pip install jsondiff==1.2.0

cd sonic-utilities

# Test building the Debian package
sudo python setup.py --command-packages=stdeb.command bdist_deb

EOF

chmod 755 build_sonic_utilities.sh

# Build sonic-utilities and copy resulting Debian package
docker login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWD sonicdev-microsoft.azurecr.io:443
docker pull sonicdev-microsoft.azurecr.io:443/sonic-slave-stretch-johnar:latest
docker run --rm=true --privileged -v $(pwd):/sonic -w /sonic -i sonicdev-microsoft.azurecr.io:443/sonic-slave-stretch-johnar ./build_sonic_utilities.sh

cp sonic-utilities/deb_dist/python-sonic-utilities_*.deb buildimage/target/python-debs/
