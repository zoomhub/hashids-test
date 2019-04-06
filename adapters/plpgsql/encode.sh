#/bin/bash

set -euo pipefail

if [[ -z "$HASHIDS_MIN_LENGTH" ]]; then
    echo "'HASHIDS_MIN_LENGTH' is required"
    exit 1;
fi

if [[ -z "$HASHIDS_ID" ]]; then
    echo "'HASHIDS_ID' is required"
    exit 1;
fi

psql \
    --dbname hashids-test \
    --no-align \
    --tuples-only \
    --command "SELECT hashids.encode( number := $HASHIDS_ID, min_length := $HASHIDS_MIN_LENGTH, salt := '$HASHIDS_SALT');"
