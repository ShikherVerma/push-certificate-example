#!/usr/bin/bash 

source functions.sh
set -e #failerr

# clean up from possible previous iterations
cleanup server

# create our git repositoriy
mkdir -p server/signed-repo.git && cd server/signed-repo.git
git init --bare
touch git-daemon-export-ok  # git daemon only pushes repos with this magic file
git config receive.certNonceSeed 1000  # necessary for signed push
git config receive.certNonceSlop 1000  # necessary for signed push
# set up our post-receive hook to handle the certificates.
cp ../../hook.sh hooks/post-receive && chmod +x hooks/post-receive
# actually listen. We will send the log to a logfile to avoid polluting our stdout 
git daemon --verbose --reuseaddr --informative-errors --enable=receive-pack \
    --base-path=$PWD/.. > server.log 2>server.err &
DAEMON_PID=$!
# go back to the root of the server dir
cd ..
echo "Server running, now you should be able to clone+push on git://localhost/signed-repo.git"
# client 1. Pushes a new branch.
echo "Running Client 1 who pushes test branch"
source ../client1.sh
# client 2. pull the new branch.
echo "Running Client 2 who pulls test branch"
source ../client2.sh

# see the files in the server and client 2.
echo -e "\e[1mobjects in the pack file on client2\e[0m"
git verify-pack -v client2/signed-repo/.git/objects/pack/pack-*.idx
echo ""
echo -e "\e[1mObjects on the server"
tree signed-repo.git/objects
echo ""
echo "killing the server"
kill -15 $DAEMON_PID
