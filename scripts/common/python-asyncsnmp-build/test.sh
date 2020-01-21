#!/bin/bash -xe
## Run unit test
## TODO: add pytest as test requirement, and remove below line
sudo python3.6 -m pip install pytest>=3.0.5 mockredispy>=2.9.3 mock>=2.0.0
## go to the source code dir to run test
pushd sonic-snmpagent
sudo python3.6 -m pip install dist/asyncsnmp-2.1.0-py3-none-any.whl
##sudo python3.6 -m pip install -e ".[testing]"
python3.6 -m pytest -s
popd
