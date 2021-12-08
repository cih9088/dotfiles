#!/usr/bin/env bash

# PLATFORM
case "$OSTYPE" in
  solaris*) PLATFORM="SOLARIS" ;;
  darwin*)  PLATFORM="OSX" ;;
  linux*)   PLATFORM="LINUX" ;;
  bsd*)     PLATFORM="BSD" ;;
  msys*)    PLATFORM="WINDOWS" ;;
  *)        PLATFORM="unknown: $OSTYPE" ;;
esac

# ID, ID_LIKE, FAMILY
if [[ $PLATFORM == LINUX ]]; then
  source <(grep ID /etc/os-release)
  FAMILY=""
  if [[ " rhel centos fedora rocky " =~ " ${ID} " ]]; then
    FAMILY="RHEL"
  elif [[ " ubuntu debian " =~ " ${ID} " ]]; then
    FAMILY="DEBIAN"
  fi
fi

# ARCH
ARCH=$(uname -m)
if [ $ARCH == "arm64" ]; then
  ARCH="aarch64"
fi
