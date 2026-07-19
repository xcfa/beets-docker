#!/bin/sh
set -e

# Wire up the user-managed package directory: everything pip-installed inside
# the container goes there, and python picks it up via PYTHONPATH.
if [ -n "${BEETS_EXTRA_PACKAGES}" ]; then
    mkdir -p "${BEETS_EXTRA_PACKAGES}"
    export PYTHONPATH="${BEETS_EXTRA_PACKAGES}${PYTHONPATH:+:${PYTHONPATH}}"
    export PIP_TARGET="${BEETS_EXTRA_PACKAGES}"

    # Auto-install user requirements once per requirements.txt revision.
    req="${BEETS_EXTRA_PACKAGES}/requirements.txt"
    stamp="${BEETS_EXTRA_PACKAGES}/.requirements.installed"
    if [ -f "${req}" ]; then
        if [ ! -f "${stamp}" ] || ! cmp -s "${req}" "${stamp}"; then
            echo "Installing user packages from ${req} into ${BEETS_EXTRA_PACKAGES}"
            pip install --no-cache-dir --upgrade -r "${req}"
            cp "${req}" "${stamp}"
        fi
    fi
fi

exec "$@"
