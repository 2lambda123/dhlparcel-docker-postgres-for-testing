FROM postgis/postgis:11-2.5-alpine

COPY ./config.sh        /docker-entrypoint-initdb.d/0-config.sh
COPY ./create_db.sh     /docker-entrypoint-initdb.d/20-create_db.sh

ENV POSTGRES_HOST_AUTH_METHOD trust
