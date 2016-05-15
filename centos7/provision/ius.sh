#!/bin/bash
set -ex

function add_ius_rpm_package_repo()
{
  curl -o ius.sh setup.ius.io
  sh ius.sh
  {
    yum clean all
    yum update -y
  }
  rm ius.sh
}
