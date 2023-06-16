#!/usr/bin/env bash

#CHEF_HABITAT_AUTH_TOKEN=<YOUR_PAT>
#CHEF_HABITAT_BUILDER_URL=<YOUR_BUILDER_URL>
#CHEF_HABITAT_CHANNEL=<PACKAGE_CHANNEL>
CHEF_HABITAT_CLI=/usr/bin/hab
CHEF_HABITAT_CLI_DEFAULT_INSTALL_URL=https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.sh
#CHEF_HABITAT_CLI_INSTALL_URL=<YOUR_CLI_INSTALL_URL>
CHEF_HABITAT_DEFAULT_BUILDER_URL=https://bldr.habitat.sh
CHEF_HABITAT_DEFAULT_CHANNEL=unstable
#CHEF_HABITAT_ORIGIN=<PACKAGE_ORIGIN>
#CHEF_HABITAT_SHOULD_UPLOAD_PACKAGE=ON

echo "[Build] Script begin"

if $CHEF_HABITAT_CLI --version &> /dev/null; then
  echo "[Build] Chef Habitat CLI is installed"
else
  if [[ -z "$CHEF_HABITAT_CLI_INSTALL_URL" ]] ; then
    echo "[Build] CHEF_HABITAT_CLI_INSTALL_URL is not set. Use CHEF_HABITAT_CLI_DEFAULT_INSTALL_URL"
    export CHEF_HABITAT_CLI_INSTALL_URL=$CHEF_HABITAT_CLI_DEFAULT_INSTALL_URL
  fi
  echo "[Build] Installing Chef Habitat CLI"
  curl $CHEF_HABITAT_CLI_INSTALL_URL | sudo bash
fi

echo "[Build] Apply Chef Habitat CLI license (non-persistent mode)"
export HAB_LICENSE=accept-no-persist

if [[ -z "$CHEF_HABITAT_BUILDER_URL" ]] ; then
  echo "[Build] CHEF_HABITAT_BUILDER_URL is not set. Use CHEF_HABITAT_DEFAULT_BUILDER_URL"
  export CHEF_HABITAT_BUILDER_URL=$CHEF_HABITAT_DEFAULT_BUILDER_URL
fi
echo "[Build] Apply Chef Habitat Builder URL"
export HAB_BLDR_URL=$CHEF_HABITAT_BUILDER_URL

if [[ -z "$CHEF_HABITAT_ORIGIN" ]] ; then
  echo "[Build] CHEF_HABITAT_ORIGIN should be set. exit"
  exit 1
else
  echo "[Build] Apply package origin"
  export HAB_ORIGIN=$CHEF_HABITAT_ORIGIN
fi

if [[ -z "$CHEF_HABITAT_CHANNEL" ]] ; then
  echo "[Build] CHEF_HABITAT_CHANNEL is not set. Use CHEF_HABITAT_DEFAULT_CHANNEL"
  export CHEF_HABITAT_CHANNEL=$CHEF_HABITAT_DEFAULT_CHANNEL
fi

if [[ -z "$CHEF_HABITAT_AUTH_TOKEN" ]] ; then
  echo "[Build] CHEF_HABITAT_AUTH_TOKEN should be set. exit"
  exit 1
else
  echo "[Build] Apply Chef Habitat auth token"
  export HAB_AUTH_TOKEN=$CHEF_HABITAT_AUTH_TOKEN
fi

echo "[Build] Download public key from package origin"
$CHEF_HABITAT_CLI origin key download $CHEF_HABITAT_ORIGIN
echo "[Build] Download secret key from package origin"
$CHEF_HABITAT_CLI origin key download --secret $CHEF_HABITAT_ORIGIN

echo "[Build] Build package"
$CHEF_HABITAT_CLI pkg build .
PKG_BUILD_EXIT_CODE=$?
if [ $PKG_BUILD_EXIT_CODE -ne 0 ] ; then
  exit $PKG_BUILD_EXIT_CODE
fi

if [[ ! $CHEF_HABITAT_SHOULD_UPLOAD_PACKAGE = "ON" ]] ; then
  echo "[Build] Skip uploading package"
else
  echo "[Build] Upload package"
  ls results/*.hart -Art | tail -n 1 | xargs $CHEF_HABITAT_CLI pkg upload --channel $CHEF_HABITAT_CHANNEL
fi

echo "[Build] Script end"
