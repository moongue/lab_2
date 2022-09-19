#!/bin/bash

SERVER_HOST_DIR=/home/thomasmorgan/apps/project_mern_memories/server
CLIENT_HOST_DIR=/home/thomasmorgan/apps/project_mern_memories/client

# destination folder names can be changed
SERVER_REMOTE_DIR=/var/app/server
CLIENT_REMOTE_DIR=/var/www/client

check_remote_dir_exists() {
  echo "Check if remote directories exist"

  if ssh %ssh_alias% "[ ! -d $1 ]"; then
    echo "Creating: $1"
	ssh -t %ssh_alias% "sudo bash -c 'mkdir -p $1 && chown -R %your_ssh_user_name%: $1'"
  else
    echo "Clearing: $1"
    ssh %ssh_alias% "sudo -S rm -r $1/*"
  fi
}

check_remote_dir_exists $SERVER_REMOTE_DIR
check_remote_dir_exists $CLIENT_REMOTE_DIR

echo "---> Building and copying server files - START <---"
echo $SERVER_HOST_DIR
cd $SERVER_HOST_DIR && scp -Cr ./ %ssh_alias%:$SERVER_REMOTE_DIR
echo "---> Building and transfering server - COMPLETE <---"

echo "---> Building and transfering client files, cert and ngingx config - START <---"
echo $CLIENT_HOST_DIR
cd $CLIENT_HOST_DIR && npm run build
scp -Cr $CLIENT_HOST_DIR/build/* my-cert.{crt,key} nginx.conf %ssh_alias%:$CLIENT_REMOTE_DIR
echo "---> Building and transfering - COMPLETE <---"