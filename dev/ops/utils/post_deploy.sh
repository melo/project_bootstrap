#!/bin/sh

set -e

PRJROOT=`pwd`
export PRJROOT

### Setup our environment
echo "** Setting up our environment for deployment on '$PRJROOT'"
## FIXME: this should be a ENV from prj
source "$PRJROOT/devops/environment.sh" demo

### CPAN deps
echo "** Installing CPAN deps"
if [ ! -e "$PRJROOT/deps/perl5" ] ; then
  mkdir -p "$PRJROOT/deps/perl5"
fi
cpanm --quiet --notest -L "$PRJROOT/deps/perl5" --installdeps ./devops/

## Enable/Restart our services
(
  SRVDIR="$HOME/service"
  export SRVDIR

  for srv in `ls -1 service | sort` ; do
    if [ -e "$SRVDIR/$srv" ] ; then
      echo "** Restarting $srv"
      svc -dx "$SRVDIR/$srv"
      svc -dx "$SRVDIR/$srv/log"
    else
      echo "** Starting up service $srv"
      ln -s "$PRJROOT/service/$srv" "$SRVDIR/$srv"
    fi
  done
)
