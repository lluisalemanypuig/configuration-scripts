#!/bin/bash

set -ex

if [ -z "$1" ]; then
	echo "Please provide the new branch's name"
	exit 1
fi

new_branch=$1
base_branch=${2:-dev}

echo "Using base branch: '$base_branch'"

git checkout "$base_branch"

git pull
git checkout -b "$new_branch"
git push --no-verify -u origin "$new_branch"
