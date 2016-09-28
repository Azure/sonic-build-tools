FROM debian:jessie

MAINTAINER johnar@microsoft.com

RUN echo "deb http://debian-archive.trafficmanager.net/debian/ jessie main contrib non-free" > /etc/apt/sources.list
RUN echo "deb-src http://debian-archive.trafficmanager.net/debian/ jessie main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://debian-archive.trafficmanager.net/debian-security/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://debian-archive.trafficmanager.net/debian-security/ jessie/updates main contrib non-free" >> /etc/apt/sources.list

RUN apt-get clean && apt-get update && apt-get install -y  apt-utils default-jre-headless openssh-server curl wget unzip git build-essential libtool lintian

RUN apt-get update && apt-get install -y sudo dh-make dh-exec kmod libtinyxml2-2 libboost-program-options1.55-dev libtinyxml2-dev python python-pip libnl-3-dev libnl-route-3-dev libncurses5-dev texinfo dh-autoreconf
RUN apt-get update && apt-get install -y doxygen devscripts git-buildpackage perl-modules libswitch-perl dh-systemd

# For quagga build
RUN apt-get update && apt-get install -y libreadline-dev texlive-latex-base texlive-generic-recommended texlive-fonts-recommended libpam0g-dev libpam-dev libcap-dev imagemagick ghostscript groff libpcre3-dev gawk chrpath libsnmp-dev

# For libnl3 (local) build
RUN apt-get install -y cdbs

# For sswsdk build
RUN apt-get update && apt-get install -y libhiredis-dev

# For linux build
RUN apt-get update && apt-get install -y bc fakeroot build-essential devscripts quilt stgit
RUN apt-get update && apt-get -y build-dep linux

# For platform-modules build
RUN apt-get update && apt-get install -y module-assistant

# For thrift build
RUN apt-get update && apt-get install -y gem2deb libboost-all-dev libevent-dev libglib2.0-dev libqt4-dev python-all-dev python-twisted php5-dev phpunit libbit-vector-perl openjdk-7-jdk javahelper maven-debian-helper ant libmaven-ant-tasks-java libhttpclient-java libslf4j-java libservlet3.1-java qt5-default

# For mellanox sdk build
RUN apt-get update && apt-get install -y libpcre3 libpcre3-dev byacc flex libglib2.0-dev bison expat libexpat1-dev dpatch libdb-dev iptables-dev swig

# For mellanox sai build
RUN apt-get update && apt-get install -y libtool-bin libxml2-dev

# For build image
RUN apt-get update && apt-get install -y cpio squashfs-tools zip

# For broadcom sdk build
RUN apt-get update && apt-get install -y linux-compiler-gcc-4.8-x86 linux-kbuild-3.16

# teamd build
RUN apt-get update && apt-get install -y libdaemon-dev libdbus-1-dev libjansson-dev libnl-cli-3-dev libnl-genl-3-dev

# For cavium sdk build
RUN apt-get update && apt-get install -y libpcap-dev dnsutils libusb-dev

# For p4 build
RUN apt-get update && apt-get install -y libyaml-dev libevent-dev libjudy-dev libedit-dev libpcap-dev libnanomsg-dev
RUN apt-get update && apt-get install -y python-stdeb

RUN useradd -d /var/build -m -s /bin/bash build
COPY sonic-jenkins-id_rsa.pub /var/build/.ssh/authorized_keys2
RUN chown build.build ~build/.ssh -R
RUN chmod go= ~build/.ssh -R

RUN mkdir /var/run/sshd
EXPOSE 22

# Allow build account root for testing
RUN echo "build ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

# For Jenkins static analysis, unit testing and code coverage
RUN apt-get update && apt-get install -y cppcheck clang pylint python-pytest gcovr python-pytest=2.6.3* python-pytest-cov python-parse

# Install depot-tools (for git-retry)
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /usr/share/depot_tools
ENV PATH /usr/share/depot_tools:$PATH

# Install docker engine 1.11.2 inside docker
RUN curl -sSL https://get.docker.com/ | sh && apt-get install -y --force-yes -q docker-engine=1.11.2-0~jessie
RUN gpasswd -a build docker
