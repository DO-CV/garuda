#!/bin/bash

function add_ius_rpm_package_repo()
{
  curl https://setup.ius.io -o ius.sh
  mv ius.sh /tmp
  sh /tmp/ius.sh
  {
    yum clean all
    yum update -y
  }
}
