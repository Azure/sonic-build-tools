#!/bin/bash -xe
## Install python3.6
sudo apt-get -y purge python3-setuptools python3-wheel
## go to the source code dir to build
pushd sonic-snmpagent
ls -l target/debs/
## sudo dpkg -i target/debs/{libmpdec2_*_amd64.deb,libpython3.6-minimal_3.6.0-1_amd64.deb,libpython3.6-stdlib_3.6.0-1_amd64.deb,python3.6-minimal_3.6.0-1_amd64.deb,libpython3.6_3.6.0-1_amd64.deb,python3.6_3.6.0-1_amd64.deb,libpython3.6-dev_3.6.0-1_amd64.deb}
sudo dpkg -i target/debs/libmpdec2_*_amd64.deb
sudo dpkg -i target/debs/libpython3.6-minimal_3.6.0-1_amd64.deb
sudo dpkg -i target/debs/libpython3.6-stdlib_3.6.0-1_amd64.deb
sudo dpkg -i target/debs/python3.6-minimal_3.6.0-1_amd64.deb
sudo dpkg -i target/debs/libpython3.6_3.6.0-1_amd64.deb
sudo dpkg -i target/debs/python3.6_3.6.0-1_amd64.deb
sudo dpkg -i target/debs/libpython3.6-dev_3.6.0-1_amd64.deb
curl https://bootstrap.pypa.io/get-pip.py | sudo python3.6
## Build
sudo python3.6 -m pip install target/python-wheels/swsssdk*-py3-*.whl
python3.6 setup.py bdist_wheel
popd
