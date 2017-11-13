#!/bin/bash

# Warning: This script installs software and messes with your "docker" binary.
# Don't run it unless you know what you are doing.

set -e
set -x

echo "SETUID=$SETUID TARBALL=$TARBALL INSTALL=$INSTALL"

case $TARBALL in
    export)
        make export
        tar xf charliecloud-*.tar.gz
        cd charliecloud-*
        ;;
    archive)
        sudo apt-get install bats
        git archive HEAD --prefix=charliecloud/ -o charliecloud.tar
        tar xf charliecloud.tar
        cd charliecloud
        ;;
esac

# We start in the Charliecloud Git working directory, so no cd needed.
make SETUID=$SETUID

if [[ $INSTALL ]]; then
    sudo make install PREFIX=/usr/local
    cd /usr/local/share/doc/charliecloud
fi

cd test

make test-quick
make test-all

# To test without Docker, move the binary out of the way.
DOCKER=$(which docker)
sudo mv $DOCKER $DOCKER.tmp

make test-all

# For Travis, this isn't really necessary, since the VM will go away
# immediately after this script exits. However, restore the binary to enable
# testing this script in other environments.
sudo mv $DOCKER.tmp $DOCKER
