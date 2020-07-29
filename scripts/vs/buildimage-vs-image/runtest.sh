#!/bin/bash -xe

tbname=$1

run_pytest()
{
    tgname=$1
    shift
    tests=$@

    echo "run tests: $tests"

    mkdir -p logs/$tgname
    for tn in ${tests}; do
        tdir=$(dirname $tn)
        if [ $tdir != "." ]; then
            mkdir -p logs/$tgname/$tdir
            mkdir -p results/$tgname/$tdir
        fi
        py.test $PYTEST_COMMON_OPTS --log-file logs/$tgname/$tn.log --junitxml=results/$tgname/$tn.xml $tn.py
    done
}

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

PYTEST_COMMON_OPTS="--inventory veos.vtb \
                    --host-pattern all \
                    --user admin \
                    -vvv \
                    --show-capture stdout \
                    --testbed $tbname \
                    --testbed_file vtestbed.csv \
                    --disable_loganalyzer \
                    --log-file-level debug"

# Check testbed health
cd /data/sonic-mgmt/tests
rm -rf logs results
mkdir -p logs
mkdir -p results
py.test $PYTEST_COMMON_OPTS --log-file logs/test_nbr_health.log --junitxml=results/tr.xml test_nbr_health.py

# Run anounce route test case in order to populate BGP route
py.test $PYTEST_COMMON_OPTS --log-file logs/test_announce_routes.log --junitxml=results/tr.xml test_announce_routes.py

# Tests to run using one vlan configuration
tgname=1vlan
tests="\
    test_interfaces \
    pc/test_po_update \
    bgp/test_bgp_fact \
    lldp/test_lldp \
    route/test_default_route \
    bgp/test_bgp_speaker \
    bgp/test_bgp_gr_helper \
    dhcp_relay/test_dhcp_relay \
    syslog/test_syslog \
    tacacs/test_rw_user \
    tacacs/test_ro_user \
    ntp/test_ntp \
    cacl/test_cacl_application \
    cacl/test_cacl_function \
    telemetry/test_telemetry \
    snmp/test_snmp_cpu \
    snmp/test_snmp_interfaces \
    snmp/test_snmp_lldp \
    snmp/test_snmp_pfc_counters \
    snmp/test_snmp_queue
"

# Run tests_1vlan on vlab-01 virtual switch
pushd /data/sonic-mgmt/tests
run_pytest $tgname $tests
popd

# Create and deploy two vlan configuration (two_vlan_a) to the virtual switch
cd /data/sonic-mgmt/ansible
./testbed-cli.sh -m veos.vtb -t vtestbed.csv deploy-mg $tbname lab password.txt -e vlan_config=two_vlan_a
sleep 180

# Tests to run using two vlan configuration
tgname=2vlans
tests="\
    dhcp_relay/test_dhcp_relay \
"

# Run tests_2vlans on vlab-01 virtual switch
pushd /data/sonic-mgmt/tests
run_pytest $tgname $tests
popd
