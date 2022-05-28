#!/bin/bash
#
# A script to reverse ssh.
#

set -e

ssh_key="$SSH_KEY"
ssh_relay_host="$SSH_RELAY_HOST"
ssh_relay_user="$SSH_RELAY_USER"
ssh_relay_key="$SSH_RELAY_KEY"

port=10022
user=$(whoami)
continue_file=/tmp/continue

mkdir -p ~/.ssh

echo -e "$ssh_key" > ~/.ssh/staging.key
chmod 600 ~/.ssh/staging.key

cat >>~/.ssh/config <<END
Host staging
    HostName $ssh_relay_host
    User $ssh_relay_user
    IdentityFile ~/.ssh/staging.key
    StrictHostKeyChecking no
END

echo "$ssh_relay_key" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

is_not_running(){ 
  set +e
  out=$(/etc/init.d/ssh status | grep "is not running")
  result=$?
  set -e
  return $?
}

# ensure the ssh server is running
if [[ "$(whoami)" == "root" ]]; then
  echo -e "\nEnsure the ssh server is running..."
  if is_not_running; then
    /etc/init.d/ssh start
  fi
else
  echo -e "\nI'm not root, hoping the sshd is up and running..."
fi

# start the reverse ssh server
echo -e "\nLaunch the reverse server..."
ssh -fN -R $port:localhost:22 -o LogLevel=ERROR staging

# Start the main loop
while true; do 

  if [ -f "$continue_file" ]; then
    echo -e "\n$continue_file detected, stopping script!\n"
    break
  fi

  echo -e "\n------------------------------"
  echo -e "SSH REVERSE SERVER IS RUNNING!\n"
  echo -e "Have this in the .ssh/config file of the relay server:"
  echo -e ""
  echo -e "\tHost reverse"
  echo -e "\t\tHostName localhost"
  echo -e "\t\tStrictHostKeyChecking no"
  echo -e "\t\tPort 10022"
  echo -e "\t\tRequestTTY force"
  echo -e "\t\tRemoteCommand /bin/bash"
  echo -e "\nThen run:\n"
  echo -e "\tssh $user@reverse\n"
  echo -e "\nTo stop this, from the reverse shell:\n"
  echo -e "\trssh-stop\n"
  echo -e "or:\n"
  echo -e "\ttouch $continue_file\n"

  sleep 20

done
