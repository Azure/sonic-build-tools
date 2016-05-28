FROM debian:jessie

RUN apt-get update 
RUN apt-get upgrade -y

#Some general build artifiacts
RUN apt-get install -y bison build-essential byacc cmake cpio dh-make dh-buildinfo dh-make-perl dh-python  dh-systemd doxygen dpatch expat exuberant-ctags fakeroot flex g++ gcc git iptables-dev libdb-dev libexpat1-dev libglib2.0-dev libhiredis-dev libnl-3-dev libnl-route-3-dev libpam-dev libpcap-dev libpcre3 libpcre3-dev libreadline-dev libtool-bin libxml2-dev linux-headers-amd64 make pbuilder python python-pip python2.7-dev quagga redis-server swig vim 


# For Jenkins static analysis, unit testing and code coverage
RUN apt-get install -y cppcheck clang pylint python-pytest gcovr python-pytest=2.6.3* python-pytest-cov python-parse


