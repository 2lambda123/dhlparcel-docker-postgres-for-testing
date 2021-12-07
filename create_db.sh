#!/bin/bash
set -e
set -u

# Default variables
POSTGRES_USER="${POSTGRES_USER:-}"
POSTGRES_DB="${POSTGRES_DB:-$POSTGRES_USER}"
POSTGRES_MULTIPLE_DATABASES="${POSTGRES_MULTIPLE_DATABASES:-}"
POSTGRES_EXTENSIONS="${POSTGRES_EXTENSIONS:-}"
POSTGRES_EXTENSION_SIMPLE_UNACCENT="${POSTGRES_EXTENSION_SIMPLE_UNACCENT:-}"

if [ -z "$POSTGRES_USER" ]; then
    RED='\033[0;31m'
    echo -e "${RED}This docker image requires the parameter 'POSTGRES_USER', please add this to your docker-compose!"
    exit 1
fi

psql=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" )

# Setup multiple branches
DATABASES="$(echo ${POSTGRES_MULTIPLE_DATABASES} | tr ',' ' ')"
EXTRA=""

if [ -n "${POSTGRES_MULTIPLE_DATABASES}" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"

	for DB in $DATABASES; do
        echo "  Creating user and database '$DB'"
        "${psql[@]}" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE USER "$DB";
            CREATE DATABASE "$DB";
            GRANT ALL PRIVILEGES ON DATABASE "$DB" TO "$DB";
EOSQL
	done
	echo "Multiple databases created"
    echo ""
fi

if [ -n "${POSTGRES_EXTENSIONS}" ]; then
	echo "Multiple extensions requested: $POSTGRES_EXTENSIONS"

    EXTENSIONS="$(echo $POSTGRES_EXTENSIONS | sed 's/,/\n/g')"
    EXTENSIONS=`echo -e "$EXTENSIONS" | sed --regexp-extended 's/^(.*)$/CREATE EXTENSION IF NOT EXISTS "\1";/'`

    if [ -n "$POSTGRES_EXTENSION_SIMPLE_UNACCENT" ]; then
        echo "Extension will be loaded with simple_unaccent configuration"

        EXTRA="
            CREATE TEXT SEARCH CONFIGURATION simple_unaccent ( COPY = simple );
            ALTER TEXT SEARCH CONFIGURATION public.simple_unaccent ALTER MAPPING FOR asciiword, asciihword, word, hword, hword_asciipart, hword_part WITH unaccent, simple;
        "
    fi

    for DB in template_postgis "$POSTGRES_DB" $DATABASES; do
        echo "  Loading PostGIS extensions into $DB"
        "${psql[@]}" --dbname="$DB" <<-EOSQL
            $EXTENSIONS
            $EXTRA
EOSQL
    done
    echo "Multiple extensions created"
fi