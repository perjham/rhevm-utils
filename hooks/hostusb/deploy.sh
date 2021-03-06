#!/bin/bash
#
# Description: Script for deploying scripts on hypervisor
#
# Author: Pablo Iranzo Gómez (Pablo.Iranzo@redhat.com)
#

HOST=$1
if [ "$HOST" == "" ];
then
	echo "No host specified, exitting..."
	exit 1
fi

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"


pushd .

echo "Getting into script folder..."
cd $DIR

echo "Copying required files..."

scp -q -o StrictHostKeyChecking=no -i /etc/pki/rhevm/keys/rhevm_id_rsa after_vm_destroy.py  $HOST:/usr/libexec/vdsm/hooks/after_vm_destroy/50_hostusb
scp -q -o StrictHostKeyChecking=no -i /etc/pki/rhevm/keys/rhevm_id_rsa before_vm_migrate_source.py  $HOST:/usr/libexec/vdsm/hooks/before_vm_migrate_source/50_hostusb
scp -q -o StrictHostKeyChecking=no -i /etc/pki/rhevm/keys/rhevm_id_rsa before_vm_start.py  $HOST:/usr/libexec/vdsm/hooks/before_vm_start/50_hostusb
scp -q -o StrictHostKeyChecking=no -i /etc/pki/rhevm/keys/rhevm_id_rsa sudoers.vdsm_hook_hostusb  $HOST:/etc/sudoers.d/50_vdsm_hook_hostusb

echo "Changing permissions"
ssh -q -o StrictHostKeyChecking=no  -i /etc/pki/rhevm/keys/rhevm_id_rsa $HOST chmod 440 /etc/sudoers.d/50_vdsm_hook_hostusb
ssh -q -o StrictHostKeyChecking=no  -i /etc/pki/rhevm/keys/rhevm_id_rsa $HOST chmod 755 /usr/libexec/vdsm/hooks/after_vm_destroy/50_hostusb /usr/libexec/vdsm/hooks/before_vm_start/50_hostusb /usr/libexec/vdsm/hooks/before_vm_migrate_source/50_hostusb
ssh -q -o StrictHostKeyChecking=no  -i /etc/pki/rhevm/keys/rhevm_id_rsa $HOST persist /etc/sudoers.d/50_vdsm_hook_hostusb  /usr/libexec/vdsm/hooks/after_vm_destroy/50_hostusb /usr/libexec/vdsm/hooks/before_vm_start/50_hostusb /usr/libexec/vdsm/hooks/before_vm_migrate_source/50_hostusb


echo "Restarting VDSM to reflect changes"
ssh -q -o StrictHostKeyChecking=no  -i /etc/pki/rhevm/keys/rhevm_id_rsa $HOST service vdsmd restart

popd
