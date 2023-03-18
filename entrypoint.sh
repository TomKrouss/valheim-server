#!/bin/bash

function updateServer() {
    echo "Updating Valheim Dedicated Server"
    cd $STEAMCMDDIR
    ./steamcmd.sh +force_install_dir $SERVERDIR +login anonymous +app_update $STEAMAPPID +quit
}

function installOrUpdateValheimPlus() {
    echo "Checking for Valheim Plus"
    if [ ! -z "$VHPLUS_VERSION" ]; then
        echo "Designated Valheim Plus Version is: ${VHPLUS_VERSION}"
        if [ ! -f "${SERVERDIR}/start_server_bepinex.sh" ]; then
            echo "Valheim Plus is not installed, downloading and installing now"
		    wget --max-redirect=30 -qO- https://github.com/valheimPlus/ValheimPlus/releases/download/"${VHPLUS_VERSION}"/UnixServer.tar.gz | tar xvzf - -C "${SERVERDIR}"
		    chmod +x "${SERVERDIR}/start_server_bepinex.sh"
            echo "Valheim Plus installation finished"
	    fi
    fi
}

function copyValheimPlusConfig() {
    if [ -f "${DATADIR}/valheim_plus.cfg" ]; then
        echo "Updating Valheim Plus configuration"
        cp "${DATADIR}/valheim_plus.cfg" "${SERVERDIR}/BepInEx/config/valheim_plus.cfg"
    fi
}

function initValheimPlus() {
    installOrUpdateValheimPlus
    copyValheimPlusConfig
}

function createListIfMissing() {
    echo "Checking for existing list: $1"
    if [ ! -f "${DATADIR}/$1" ]
    then
        echo "Not found, creating new $1"
        touch "${DATADIR}/$1"
    else
        echo "$1 already exists"
    fi
}

function createPermissionFiles() {
    createListIfMissing "adminlist.txt"
    createListIfMissing "bannedlist.txt"
    createListIfMissing "permittedlist.txt"
}

function startServer() {
    echo "Starting Valheim Dedicated Server"
    cd $SERVERDIR
    ./start_server_bepinex.sh -name "${VHSERVER_NAME}" -password "${VHSERVER_PASSWORD}" -port ${VHSERVER_PORT1} -public ${VHSERVER_PUBLIC}
}

updateServer
initValheimPlus
createPermissionFiles
startServer
