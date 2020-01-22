#!/bin/bash -xe

cd $HOME
mkdir -p .ssh
cp /data/pkey.txt .ssh/id_rsa
chmod 600 .ssh/id_rsa
cd /data/sonic-mgmt/ansible
./testbed-cli.sh -m veos.vtb -t vtestbed.csv refresh-dut vms-kvm-t0 lab password.txt || true
sleep 120
./testbed-cli.sh -m veos.vtb -t vtestbed.csv deploy-mg vms-kvm-t0 lab password.txt
sleep 180
export ANSIBLE_LIBRARY=/data/sonic-mgmt/ansible/library/
cd /data/sonic-mgmt/tests

tests="test_interfaces.py \
      test_bgp_fact.py \
      test_lldp.py \
      test_bgp_speaker.py \
      test_dhcp_relay.py \
      snmp/test_snmp_cpu.py \
      snmp/test_snmp_interfaces.py \
      snmp/test_snmp_lldp.py \
      snmp/test_snmp_pfc_counters.py \
      snmp/test_snmp_queue.py"

py.test --inventory veos.vtb --host-pattern all --user admin -vvv --show-capture stdout --testbed vms-kvm-t0 --testbed_file vtestbed.csv --disable_loganalyzer --junitxml=tr.xml $tests
