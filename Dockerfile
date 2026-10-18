FROM debian:trixie-slim
ARG R3_VERSION=3.13
# ImageMagick + Ghostscript: thumbnails (incl. PDF); postgresql-client: integrated backups (pg_dump 17); jq: config.json
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq imagemagick ghostscript postgresql-client \
 && mkdir -p /opt/r3 && curl -fsSL https://rei3.de/downloads/REI3_${R3_VERSION}_x64_linux.tar.gz | tar -xz -C /opt/r3 r3 config_template.json \
 && chmod 755 /opt/r3/r3 \
 && apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
COPY first-boot.sql /opt/r3/first-boot.sql
COPY railway-start /usr/local/bin/railway-start
CMD ["/usr/local/bin/railway-start"]
