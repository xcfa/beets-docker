# beets-docker

Docker image of [beets](https://beets.io) with dependencies for popular plugins preinstalled. Built automatically and published to GitHub Container Registry: `ghcr.io/xcfa/beets-docker`.

## What's inside

Python packages: `beets`, `python3-discogs-client` (discogs), `pylast` (lastgenre/lastfm), `flask` + `flask-cors` (web), `requests`, `requests-oauthlib` (beatport), `beets-vgmdb`, `pykakasi`, `pyacoustid` (chroma), `beautifulsoup4` + `langdetect` (lyrics), `Pillow` (fetchart/embedart), `python-mpd2` (mpdstats), `unidecode`.

System tools: `ffmpeg` (convert, replaygain), `fpcalc` (chroma), `flac` and `mp3val` (badfiles).

## Usage

```sh
docker compose up -d
```

or manually:

```sh
docker run -d --name beets \
  -p 8337:8337 \
  -v ./config:/config \
  -v ./music:/music \
  -v ./plugins:/plugins \
  ghcr.io/xcfa/beets-docker:latest
```

By default the container runs `beet web` on port 8337. One-off commands:

```sh
docker exec -it beets beet import /music/incoming
```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `BEETSDIR` | `/config` | Directory with `config.yaml` and the library database |
| `HOME` | `/config` | Home directory — plugin caches (`~/.cache`) persist in the volume too |
| `BEETS_EXTRA_PACKAGES` | `/plugins` | Directory for user-installed python packages |

## Installing your own python packages

The `BEETS_EXTRA_PACKAGES` directory (`/plugins` by default) is added to `PYTHONPATH` and set as the pip install target (`PIP_TARGET`). Mount it from the host — installed packages survive container re-creation.

Two ways to install:

1. Directly in the running container (the package lands in the mounted directory):

   ```sh
   docker exec -it beets pip install beets-alternatives
   ```

2. Put a `requirements.txt` into the `plugins` directory on the host — the entrypoint installs the packages on container start (and reinstalls when the file changes):

   ```
   # plugins/requirements.txt
   beets-alternatives
   beetcamp
   ```

## Image publishing

The [docker-publish.yml](.github/workflows/docker-publish.yml) workflow builds the image (linux/amd64 + linux/arm64) and publishes it to GHCR:

- push to `master` → `latest` and `master` tags;
- git tag `vX.Y.Z` → image tags `X.Y.Z`, `X.Y`, `X`;
- pull request → build only, no publishing.
