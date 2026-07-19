FROM python:3.12-slim

LABEL org.opencontainers.image.source="https://github.com/xcfa/beets-docker" \
      org.opencontainers.image.description="beets with plugin dependencies (discogs, lastfm, web, vgmdb, chroma, lyrics...)" \
      org.opencontainers.image.licenses="MIT"

# External tools used by plugins:
#   ffmpeg                - convert, replaygain (ffmpeg backend)
#   libchromaprint-tools  - fpcalc for the chroma plugin
#   flac, mp3val          - badfiles plugin
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        libchromaprint-tools \
        flac \
        mp3val \
    && rm -rf /var/lib/apt/lists/*

# Requested plugin dependencies + extras used by common beets plugins:
#   pyacoustid            - chroma
#   flask, flask-cors     - web
#   beautifulsoup4, langdetect - lyrics
#   Pillow                - fetchart/embedart artwork resizing
#   requests-oauthlib     - beatport
#   python-mpd2           - mpdstats/mpdupdate
#   unidecode             - path transliteration
RUN pip install --no-cache-dir \
        beets \
        python3-discogs-client \
        pylast \
        flask \
        flask-cors \
        requests \
        requests-oauthlib \
        beets-vgmdb \
        pykakasi \
        pyacoustid \
        beautifulsoup4 \
        langdetect \
        Pillow \
        python-mpd2 \
        unidecode

# BEETSDIR              - beets config/library location (mount it to keep state)
# HOME                  - also /config so plugin caches (~/.cache) persist,
#                         same as linuxserver/docker-beets
# BEETS_EXTRA_PACKAGES  - dir for user-installed python packages; mount it from
#                         the host so packages survive container re-creation.
#                         Inside the container `pip install <pkg>` lands there
#                         (PIP_TARGET is set by the entrypoint), and it is added
#                         to PYTHONPATH at startup.
ENV BEETSDIR=/config \
    HOME=/config \
    BEETS_EXTRA_PACKAGES=/plugins \
    PIP_NO_CACHE_DIR=1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/config", "/music", "/plugins"]
EXPOSE 8337

ENTRYPOINT ["/entrypoint.sh"]
CMD ["beet", "web", "0.0.0.0"]
