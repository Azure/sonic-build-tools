#!/bin/bash
#
# provision gemini virtual machine
#

set -ex

source /etc/os-release

function parse_yaml() {
    local yaml_file=$1
    local prefix=$2
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @ | tr @ '\034')"

    (
        sed -e '/- [^\]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |
            sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
                -e 's/\$/\\\$/g' \
                -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
                -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
                -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
            awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1], $3);
                }
            }' |
            sed -e 's/_=/+=/g' |
            awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'
    ) <"$yaml_file"
}

function unset_variables() {
    # Pulls out the variable names and unsets them.
    #shellcheck disable=SC2048,SC2206 #Permit variables without quotes
    local variable_string=($*)
    unset variables
    variables=()
    for variable in "${variable_string[@]}"; do
        tmpvar=$(echo "$variable" | grep '[+]=' | sed 's/=.*//' | sed 's/+.*//')
        variables+=("$tmpvar")
    done
    for variable in "${variables[@]}"; do
        if [ -n "$variable" ]; then
            unset "$variable"
        fi
    done
}

function create_variables() {
    local yaml_file="$1"
    local prefix="$2"
    local yaml_string
    yaml_string="$(parse_yaml "$yaml_file" "$prefix")"
    unset_variables "${yaml_string}"
    eval "${yaml_string}"
}

function create_normal_users()
{
	curl -o users.yml https://raw.githubusercontent.com/Azure/sonic-build-tools/master/users/users.yml

	create_variables users.yml

	for i in `seq 1 ${#users__name[@]}`; do
		uname=${users__name[$((i-1))]}
		ukey=${users__key[$((i-1))]}
        id $uname
        if [ $? -ne 0 ]; then
            useradd -m -s /bin/bash $uname
            usermod -a -G docker $uname
            usermod -a -G adm $uname
            usermod -a -G sudo $uname
            echo "$uname ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/100-$uname
            chmod 440 /etc/sudoers.d/100-$uname
            mkdir -p /home/$uname/.ssh
            sed -e 's/^"//' -e 's/"$//' <<<"$ukey" > /home/$uname/.ssh/authorized_keys
            chown -R $uname.$uname /home/$uname/.ssh
            chmod 700 /home/$uname/.ssh
            chmod 600 /home/$uname/.ssh/authorized_keys
        fi
    done
}

# create data partition on the 1T data disk
# find data disk, assume it is 1T
datadisk=$(lsblk -d  | grep -E '[[:space:]]1T[[:space:]]' | awk '{print $1}')
sgdisk -n 0:0:0 -t 0:8300 -c 0:data /dev/$datadisk
mkfs.ext4 /dev/${datadisk}1

mkdir /data
mount /dev/${datadisk}1 /data

# install docker
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

systemctl stop docker
sed -i 's/^ExecStart=.*$/& --data-root \/data\/docker/' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker

# create users
set +e
create_normal_users
set -e
