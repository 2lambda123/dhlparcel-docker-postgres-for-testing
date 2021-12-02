FROM postgres:14.1-alpine

ENV PGDATA /var/lib/postgresql/data
COPY ./config.sh        /docker-entrypoint-initdb.d/10-config.sh
COPY ./create_db.sh     /docker-entrypoint-initdb.d/20-create_db.sh