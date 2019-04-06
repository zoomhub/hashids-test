#/bin/bash

set -euo pipefail

parent_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P)
cd "$parent_path"

node encode.js
