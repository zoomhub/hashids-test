#/bin/bash

set -euo pipefail

dropdb --if-exists hashids-test 2> /dev/null
createdb hashids-test

psql -f vendor/hashids.sql/hashids.sql hashids-test > /dev/null
