#!/bin/sh

set -e

PRJROOT=`pwd`
export PRJROOT

deploy_env="$1"
export deploy_env

### Setup our environment
echo "** Setting up our environment for deployment of ${deploy_env} on '$PRJROOT'"
source "$PRJROOT/dev/ops/etc/environment.sh" "${deploy_env}"

### CPAN deps
echo "** Installing CPAN deps"
if [ ! -e "$PRJROOT/deps/perl5" ] ; then
  mkdir -p "$PRJROOT/deps/perl5"
fi

deps_root_dir="./dev/ops/etc/deps"
for subdir in common "${deploy_env}" ; do
  printf "    ... check ${deps_root_dir}/${subdir}"

  if [ -e "${deps_root_dir}/${subdir}/cpanfile" ] ; then
    echo ": yes"
    LANG= ./dev/ops/utils/cpanm --quiet --notest -L "$PRJROOT/deps/perl5" --installdeps "${deps_root_dir}/${subdir}"
  else
    echo ": no"
  fi
done

## Enable/Restart our services
(
  SRVDIR="$HOME/service"
  export SRVDIR

  if [ -e "$SRVDIR" ] ; then
    for srv in `ls -1 service | sort | grep -- "-${deploy_env}"` ; do
      if [ -e "$SRVDIR/$srv" ] ; then
        echo "** Restarting $srv"
        svc -dx "$SRVDIR/$srv"
        svc -dx "$SRVDIR/$srv/log"
      else
        echo "** Starting up service $srv"
        ln -s "$PRJROOT/service/$srv" "$SRVDIR/$srv"
      fi
    done
  fi
)
