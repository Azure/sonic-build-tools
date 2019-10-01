FROM docker-sonic-vs

ARG docker_container_name

ADD ["debs", "/debs"]
RUN dpkg -i /debs/libswsscommon_1.0.0_amd64.deb
RUN dpkg -i /debs/libsaimetadata_1.0.0_amd64.deb
RUN dpkg -i /debs/libsairedis_1.0.0_amd64.deb
RUN dpkg -i /debs/libsaivs_1.0.0_amd64.deb
RUN dpkg -i /debs/syncd-vs_1.0.0_amd64.deb
RUN md5sum /usr/bin/buffermgrd
RUN dpkg -i /debs/swss_1.0.0_amd64.deb
RUN md5sum /usr/bin/buffermgrd

ENTRYPOINT ["/usr/bin/supervisord"]
