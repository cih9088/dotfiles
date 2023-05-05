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

# PLATFORM_ID="rocky"
# PLATFORM_ID_LIKE="rhel centos fedora"
# PLATFORM_VERSION="8.7"
if [[ $PLATFORM == LINUX ]]; then
  source <(grep ID /etc/os-release)
  PLATFORM_ID=$ID
  PLATFORM_ID_LIKE=$ID_LIKE
  PLATFORM_VERSION=$VERSION_ID
  unset ID
  unset ID_LIKE
  unset VERSION_ID
fi

# ARCH
ARCH=$(uname -m)
if [ $ARCH == "arm64" ]; then
  ARCH="aarch64"
fi
