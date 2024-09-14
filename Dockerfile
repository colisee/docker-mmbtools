# BUILDER IMAGE
FROM jgoerzen/debian-base-minimal:bookworm AS builder
ARG  build_branch=master
ENV  DEBIAN_FRONTEND=noninteractive

## Update OS
RUN apt-get update ; \
    apt-get upgrade --yes

## Install mmbtools
RUN apt-get install --yes git ;\
    git clone \
      --branch next \
      https://github.com/opendigitalradio/dab-scripts.git \
      /root/dab-scripts ;\
    bash /root/dab-scripts/install/mmbtools-get \
     --branch ${build_branch} \
     --odr-user odr \
     install


# FINAL IMAGE
FROM jgoerzen/debian-base-minimal:bookworm
ENV  DEBIAN_FRONTEND=noninteractive

## Copy objects built in the builder phase
COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder --chown=odr:odr /home/odr /home/odr
COPY --from=builder /etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

RUN ln -s /home/odr/config/supervisor/*.conf /etc/supervisor/conf.d/ ;\
    apt-get update ;\
    apt-get upgrade --yes ;\
    apt-get install --yes \
      gstreamer1.0-plugins-good \
      libasound2 \
      libmagickwand-6.q16-dev \
      libcurl4 \
      libgstreamer1.0 \
      libgstreamer-plugins-base1.0 \
      libjack0 \
      libvlc5 vlc-plugin-base \
      libzmq5 \
      tzdata \
      libboost-system1.74.0 \
      libbladerf2 \
      libfftw3-3 \
      liblimesuite20.10-1 \
      libsoapysdr0.7 \
      libuhd3.15.0 \
      python3-cherrypy3 \
      python3-jinja2 \
      python3-pysnmp4 \
      python3-serial \
      python3-zmq \
      python3-yaml \
      supervisor ;\
    rm -rf /var/lib/apt/lists/* ;\
    useradd \
      --create-home \
      --groups dialout,audio \
      odr

## Expose ports
EXPOSE 8001-8003
EXPOSE 9001-9016
EXPOSE 9201

## Set image labels
LABEL org.opencontainers.image.vendor="Open Digital Radio"
LABEL org.opencontainers.image.description="mmbtools - Multi Media Broadcasting Tools"
LABEL org.opencontainers.image.authors="robin.alexander@netplus.ch"
