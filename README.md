# beets-docker

Docker-образ [beets](https://beets.io) с предустановленными зависимостями для популярных плагинов. Собирается автоматически в GitHub Container Registry: `ghcr.io/xcfa/beets-docker`.

## Что внутри

Python-пакеты: `beets`, `python3-discogs-client` (discogs), `pylast` (lastgenre/lastfm), `flask` + `flask-cors` (web), `requests`, `requests-oauthlib` (beatport), `beets-vgmdb`, `pykakasi`, `pyacoustid` (chroma), `beautifulsoup4` + `langdetect` (lyrics), `Pillow` (fetchart/embedart), `python-mpd2` (mpdstats), `unidecode`.

Системные утилиты: `ffmpeg` (convert, replaygain), `fpcalc` (chroma), `flac` и `mp3val` (badfiles).

## Запуск

```sh
docker compose up -d
```

или вручную:

```sh
docker run -d --name beets \
  -p 8337:8337 \
  -v ./config:/config \
  -v ./music:/music \
  -v ./plugins:/plugins \
  ghcr.io/xcfa/beets-docker:latest
```

По умолчанию контейнер запускает `beet web` на порту 8337. Разовые команды:

```sh
docker exec -it beets beet import /music/incoming
```

## Переменные среды

| Переменная | По умолчанию | Описание |
|---|---|---|
| `BEETSDIR` | `/config` | Каталог с `config.yaml` и базой библиотеки |
| `HOME` | `/config` | Домашний каталог — кэши плагинов (`~/.cache`) тоже сохраняются в томе |
| `BEETS_EXTRA_PACKAGES` | `/plugins` | Каталог для собственных python-пакетов |

## Свои python-пакеты

Каталог `BEETS_EXTRA_PACKAGES` (по умолчанию `/plugins`) добавляется в `PYTHONPATH` и назначается целью для pip (`PIP_TARGET`). Примонтируйте его с хоста — установленные пакеты переживут пересоздание контейнера.

Два способа установки:

1. Прямо в работающем контейнере (пакет попадёт в примонтированный каталог):

   ```sh
   docker exec -it beets pip install beets-alternatives
   ```

2. Положить `requirements.txt` в каталог `plugins` на хосте — entrypoint установит пакеты при старте контейнера (и переустановит при изменении файла):

   ```
   # plugins/requirements.txt
   beets-alternatives
   beetcamp
   ```

## Публикация образа

Workflow [docker-publish.yml](.github/workflows/docker-publish.yml) собирает образ (linux/amd64 + linux/arm64) и публикует в GHCR:

- push в `master` → тег `latest` и `master`;
- тег `vX.Y.Z` → тег образа `X.Y.Z`;
- pull request → только сборка без публикации.
