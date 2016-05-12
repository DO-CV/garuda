FROM centos:7

MAINTAINER "David OK" <david.ok8@gmail.com>

ADD provision.sh /provision.sh
RUN /provision.sh

RUN adduser builduser

RUN mkdir /home/builduser/rpmbuild
VOLUME /home /home/builduser/rpmbuild
WORKDIR /home/builduser/rpmbuild
