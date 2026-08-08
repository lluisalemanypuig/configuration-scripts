#!/bin/bash

set -ex

submodule=$1

if [ -z $submodule ]; then
	echo "Submodule name not given"
	exit
fi

git submodule update --init $submodule
