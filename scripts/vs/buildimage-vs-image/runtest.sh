#!/bin/bash -xe

cd $HOME
mkdir -p .ssh
cp /data/pkey.txt .ssh/id_rsa
chmod 600 .ssh/id_rsa

# Refresh virtual switch with vms-kvm-t0 topology
cd /data/sonic-mgmt/ansible
./testbed-cli.sh -m veos.vtb -t vtestbed.csv refresh-dut vms-kvm-t0 lab password.txt || true
sleep 120

# Create and deploy default vlan configuration (one_vlan_a) to the virtual switch
./testbed-cli.sh -m veos.vtb -t vtestbed.csv deploy-mg vms-kvm-t0 lab password.txt
sleep 180

cd /data/sonic-mgmt/tests
# Run anounce route test case in order to populate BGP route
ANSIBLE_LIBRARY=/data/sonic-mgmt/ansible/library/ \
    py.test --inventory veos.vtb --host-pattern all --user admin -vvv --show-capture stdout --testbed vms-kvm-t0 \
            --testbed_file vtestbed.csv --disable_loganalyzer --junitxml=tr.xml test_announce_routes.py

# Tests to run using one vlan configuration
tests_1vlan="\
    test_interfaces.py \
    test_bgp_fact.py \
    test_lldp.py \
    test_bgp_speaker.py \
    test_dhcp_relay.py \
    snmp/test_snmp_cpu.py \
    snmp/test_snmp_interfaces.py \
    snmp/test_snmp_lldp.py \
    snmp/test_snmp_pfc_counters.py \
    snmp/test_snmp_queue.py \
"

# Run tests_1vlan on vlab-01 virtual switch
ANSIBLE_LIBRARY=/data/sonic-mgmt/ansible/library/ \
    py.test --inventory veos.vtb --host-pattern all --user admin -vvv --show-capture stdout --testbed vms-kvm-t0 \
            --testbed_file vtestbed.csv --disable_loganalyzer --junitxml=tr_1vlan.xml $tests_1vlan

# Create and deploy two vlan configuration (two_vlan_a) to the virtual switch
cd /data/sonic-mgmt/ansible
./testbed-cli.sh -m veos.vtb -t vtestbed.csv deploy-mg vms-kvm-t0 lab password.txt -e vlan_config=two_vlan_a
sleep 180

# Tests to run using two vlan configuration
tests_2vlans="\
    test_dhcp_relay.py \
"

cd /data/sonic-mgmt/tests
# Run tests_2vlans on vlab-01 virtual switch
ANSIBLE_LIBRARY=/data/sonic-mgmt/ansible/library/ \
    py.test --inventory veos.vtb --host-pattern all --user admin -vvv --show-capture stdout --testbed vms-kvm-t0 \
            --testbed_file vtestbed.csv --disable_loganalyzer --junitxml=tr_2vlans.xml $tests_2vlans
