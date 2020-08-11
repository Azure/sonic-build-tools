FROM docker-sonic-vs

ADD ["debs", "/debs"]

RUN dpkg -i common/libswsscommon_*.deb

RUN dpkg -i /debs/libsaimetadata_1.0.0_amd64.deb
RUN dpkg -i /debs/libsairedis_1.0.0_amd64.deb
RUN dpkg -i /debs/libsaivs_1.0.0_amd64.deb
RUN dpkg -i /debs/syncd-vs_1.0.0_amd64.deb

RUN dpkg -i /debs/swss_1.0.0_amd64.deb

ENTRYPOINT ["/usr/bin/supervisord"]
