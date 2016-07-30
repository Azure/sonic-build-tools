FROM debian:jessie

MAINTAINER johnar@microsoft.com

RUN sed -i "s://httpredir\.debian\.org/://ftp.us.debian.org/:" /etc/apt/sources.list
RUN echo "deb-src http://ftp.us.debian.org/debian jessie main" >> /etc/apt/sources.list

RUN apt-get clean && apt-get update && apt-get install -y  apt-utils default-jre-headless openssh-server curl wget unzip git build-essential libtool lintian

RUN apt-get install -y sudo dh-make kmod libtinyxml2-2 libboost-program-options1.55-dev libtinyxml2-dev python python-pip libnl-3-dev libnl-route-3-dev libncurses5-dev texinfo dh-autoreconf
RUN apt-get install -y doxygen devscripts git-buildpackage perl-modules libswitch-perl dh-systemd

# For quagga build
RUN apt-get install -y libreadline-dev texlive-latex-base texlive-generic-recommended texlive-fonts-recommended libpam0g-dev libpam-dev libcap-dev imagemagick ghostsc
ript groff libpcre3-dev gawk chrpath libsnmp-dev

# For sswsdk build
RUN apt-get install -y libhiredis-dev

# For linux build
RUN apt-get install -y bc fakeroot build-essential devscripts quilt stgit
RUN apt-get -y build-dep linux

# For platform-modules build
RUN apt-get update && apt-get install -y module-assistant

# For thrift build
RUN apt-get update && apt-get install -y gem2deb libboost-all-dev libevent-dev libglib2.0-dev libqt4-dev python-all-dev python-twisted php5-dev phpunit libbit-vector-
perl openjdk-7-jdk javahelper maven-debian-helper ant libmaven-ant-tasks-java libhttpclient-java libslf4j-java libservlet3.1-java

# For build image
RUN apt-get update && apt-get install -y cpio

# teamd build
RUN apt-get update && apt-get install -y libdaemon-dev libdbus-1-dev libjansson-dev libnl-cli-3-dev libnl-genl-3-dev

