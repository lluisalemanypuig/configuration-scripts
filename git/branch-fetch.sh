#!/bin/bash

set -ex

branch=$1

if [ -z $branch ]; then
	echo "Branch name not provided"
	exit
fi

current_branch=$(git branch --show-current)

if [ $? -eq 1 ]; then
	echo "Failed fetching the current branch"
	exit
fi

if [ "$branch" == "$current_branch" ]; then
	echo "Fetching the same branch as the current one is not allowed."
	exit
fi

git checkout dev
git fetch origin $branch
git checkout $branch
git pull
