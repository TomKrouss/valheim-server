FROM cm2network/steamcmd:latest as base
LABEL maintainer="Thomas Krouß"

ARG PORT1
ARG PORT2

ENV DEBIAN_FRONTEND="noninteractive"
ENV USER="vhserver"
ENV SERVERDIR="/home/${USER}/server"
ENV STEAMAPPID=896660
ENV DATADIR="/home/${USER}/data/"
ENV VHSERVER_PORT1=${PORT1}
ENV VHSERVER_PORT2=${PORT2}

USER root

RUN useradd -m -G steam "${USER}" \
    && mkdir -p "${DATADIR}" \
    && chown -R "${USER}" "${DATADIR}" \
    && chmod -R g+rwx "${STEAMCMDDIR}" \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        wget \
        file \
        tini \
        libc6-dev \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/*

FROM base as server

USER ${USER}

RUN mkdir -p "${SERVERDIR}" \
    && cd "${STEAMCMDDIR}" \
    && './steamcmd.sh' +force_install_dir "${SERVERDIR}" +login anonymous +app_update "${STEAMAPPID}" +quit 

FROM server as run

COPY --chown=${USER} ./valheim_plus.cfg ${DATADIR}/valheim_plus.cfg
COPY --chown=${USER} ./entrypoint.sh /entrypoint.sh

RUN chmod u+x "/entrypoint.sh"

EXPOSE ${VHSERVER_PORT1}/udp
EXPOSE ${VHSERVER_PORT2}/udp
EXPOSE ${VHSERVER_PORT1}/tcp
EXPOSE ${VHSERVER_PORT2}/tcp

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]