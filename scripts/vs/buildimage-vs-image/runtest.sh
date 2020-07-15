#!/bin/bash -xe

tbname=$1
dut=$2

cd $HOME
mkdir -p .ssh
cp /data/pkey.txt .ssh/id_rsa
chmod 600 .ssh/id_rsa

# Refresh dut in the virtual switch topology
cd /data/sonic-mgmt/ansible
./testbed-cli.sh -m veos.vtb -t vtestbed.csv refresh-dut $tbname password.txt
sleep 120

# Create and deploy default vlan configuration (one_vlan_a) to the virtual switch
./testbed-cli.sh -m veos.vtb -t vtestbed.csv deploy-mg $tbname lab password.txt
sleep 180

export ANSIBLE_LIBRARY=/data/sonic-mgmt/ansible/library/

# workaround for issue https://github.com/Azure/sonic-mgmt/issues/1659
export export ANSIBLE_KEEP_REMOTE_FILES=1

PYTEST_CLI_COMMON_OPTS="\
    -i veos.vtb \
    -d $dut \
    -n $tbname \
    -f vtestbed.csv \
    -k debug \
    -l warning \
    -m group \
    -e --disable_loganalyzer
"

cd /data/sonic-mgmt/tests
rm -rf logs
mkdir -p logs

# Run tests_1vlan on vlab-01 virtual switch
# TODO: Use a marker to select these tests rather than providing a hard-coded list here.
tgname=1vlan
tests="\
test_interfaces.py \
bgp/test_bgp_fact.py \
bgp/test_bgp_gr_helper.py \
bgp/test_bgp_speaker.py \
cacl/test_cacl_application.py \
cacl/test_cacl_function.py \
dhcp_relay/test_dhcp_relay.py \
lldp/test_lldp.py \
ntp/test_ntp.py \
pc/test_po_update.py \
route/test_default_route.py \
snmp/test_snmp_cpu.py \
snmp/test_snmp_interfaces.py \
snmp/test_snmp_lldp.py \
snmp/test_snmp_pfc_counters.py \
snmp/test_snmp_queue.py \
syslog/test_syslog.py \
tacacs/test_rw_user.py \
tacacs/test_ro_user.py \
telemetry/test_telemetry.py"

pushd /data/sonic-mgmt/tests
./run_tests.sh $PYTEST_CLI_COMMON_OPTS -c "$tests" -p logs/$tgname
popd

# Create and deploy two vlan configuration (two_vlan_a) to the virtual switch
cd /data/sonic-mgmt/ansible
./testbed-cli.sh -m veos.vtb -t vtestbed.csv deploy-mg $tbname lab password.txt -e vlan_config=two_vlan_a
sleep 180

# Run tests_2vlans on vlab-01 virtual switch
tgname=2vlans
tests="dhcp_relay/test_dhcp_relay.py"

pushd /data/sonic-mgmt/tests
./run_tests.sh $PYTEST_CLI_COMMON_OPTS -c "$tests" -p logs/$tgname
popd
