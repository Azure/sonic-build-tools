FROM ubuntu:bionic

RUN apt-get update  # 20210106 invalidate docker build cache
RUN apt-get install -y make libtool m4 autoconf dh-exec debhelper cmake pkg-config \
                       libhiredis-dev libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev swig3.0 \
                       libpython2.7-dev libgtest-dev libboost-dev

RUN apt-get install -y sudo
RUN apt-get install -y redis-server redis-tools
RUN apt-get install -y python-pip

RUN apt-get install -y python3 python3-dev

RUN pip install pytest

RUN apt-get install cmake libgtest-dev
RUN cd /usr/src/gtest && cmake . && make
