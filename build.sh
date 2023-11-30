#!/usr/bin/env bash

# Source
# https://render.com/docs/deploy-phoenix#create-a-build-script

# exit on error

CLEAN="0"

if [ $# == 1 ]; then
    if [ $1 == "clean-build" ]
    then
        CLEAN="1"
    else
        echo "second argument should be 'clean-build'.
This removes all depedency and build directories"
        exit
    fi
fi

set -xo errexit

if [ "$CLEAN" == "1" ]
then
    echo "****** removing dependeny and build directories ******"
    # Removing so that target tripe debuilds

    cd ./assets
    npm cache clean -f
    cd ..
    echo $(pwd)
    rm -f -r ./assets/node_modules/
    rm -f -r ./deps/
    rm -f -r ./_build/
fi

echo "****** mix local.hex & local.rebar ******"
mix local.hex --force
mix local.rebar --force
# Initial setup

# if clean then build production dependencies only
# mix deps.get --only prod
# Not using only prod for now
echo "****** Clean Dependencies & Build Prod Dependencies ******"
mix deps.clean --all
mix deps.get --only prod

echo "****** Compile ******"
MIX_ENV=prod mix compile
# MIX_ENV=prod mix ua_inspector.download --force

# Compile assets
echo "****** Compile Assets ******"
npm install --prefix ./assets
# npm run deploy --prefix ./assets
# MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix assets.deploy

echo "****** Build Release ******"
# Build the release and overwrite the existing release directory
MIX_ENV=prod mix phx.gen.release
MIX_ENV=prod mix release --overwrite
# Remove Digested Files So It Is Not Commited To Git
MIX_ENV=prod mix phx.digest.clean --all

echo "****** Copy Release To Release Directory ******"
if [ "$IN_VAGRANT" = "1" ]; then
    cp -p -v -f ./_build/prod/planet* /tmp/release
else
    cp -p -v -f ./_build/prod/planet* ./release
    # Running this to fetch all dependencies again
fi

# Refresh Dependencides on MacOS Local Build
if [ "$IN_MAC_LOCAL" = "1" ]; then
    mix deps.get
    mix compile
fi



### Steps
# Download from S3
# Check if 4000 is being used
# # If Yes
#     -> Start At Port 4001 [APP]
# # If No
#     -> Start At Port 4000

# Caddy Update Reverse Proxy to Add [APP]:Port to Caddyfile

# Caddy Reload
