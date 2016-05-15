#!/bin/bash
set -ex


function add_ius_rpm_package_repo()
{
  curl https://setup.ius.io -o ius.sh
  sh ius.sh
  {
    yum clean all
    yum update -y
  }
  rm ius.sh
}


add_ius_rpm_package_repo
