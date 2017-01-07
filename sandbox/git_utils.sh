#!/bin/bash
set -ex


function clean_git_repo()
{
  local package=$1
  local origin=$2

  echo "Resetting git repo $package to master..."
  cd $package
  git clean -fdx
  git reset --hard HEAD
  git fetch $origin --prune
  git pull $origin master
  cd ..
}


function make_clean_build_dir()
{
  local library=$1

  # Delete the existing build directory to rebuild from scratch.
  if [ -d "${library}-build" ]; then
    rm -rf ${library}-build
  fi

  # Make the build directory again.
  mkdir ${library}-build
}
