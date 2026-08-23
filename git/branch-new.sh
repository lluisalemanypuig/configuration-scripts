#!/bin/bash

set -ex

new_branch=$1
base_branch=${2:-dev}

if [ -z "$new_branch" ]; then
	echo "New branch name not provided"
	exit 1
fi
if [ -z "$base_branch" ]; then
	echo "Base branch name not provided"
	exit 1
fi

echo "Using base branch: '$base_branch'"

git checkout "$base_branch"

git pull
git checkout -b "$new_branch"
git push --no-verify -u origin "$new_branch"
