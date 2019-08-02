FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y make libtool m4 autoconf dh-exec debhelper cmake pkg-config \
                       libhiredis-dev libnl-3-dev libnl-genl-3-dev libnl-route-3-dev swig3.0 \
                       libpython2.7-dev libgtest-dev

RUN apt-get install -y sudo
RUN apt-get install -y redis-server redis-tools
RUN apt-get install -y python-pip

RUN pip install pytest

RUN apt-get install cmake libgtest-dev
RUN cd /usr/src/gtest && cmake . && make
