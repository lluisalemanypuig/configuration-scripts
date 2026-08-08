#!/bin/bash

set -ex

from_branch=$1

if [ -z "$from_branch" ]; then
	echo "Branch name to rebase from was not given"
	exit
fi

current_branch=$(git branch --show-current)

if [ $? -eq 1 ]; then
	echo "Failed fetching the current branch"
	exit
fi

if [[ "$from_branch" == "$current_branch" ]]; then
	echo "Cannot rebase a branch onto itself"
	echo "from_branch:    $from_branch"
	echo "current_branch: $current_branch"
	exit
fi

# update current_branch -- maybe you forgot to pull the changes by copilot review
git pull

# update from_branch
git checkout $from_branch

git pull

# rebase from_branch into current_branch
git checkout $current_branch
echo "Rebasing $from_branch into $current_branch"
git rebase $from_branch
