#!/bin/bash
# Kernel launcher that isolates the pixi env from HPC module-system contamination.
# Prepends the pixi env's lib/ to LD_LIBRARY_PATH so the correct libproj / libgdal
# are loaded instead of whatever the HPC module system injected.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIXI_ENV="$SCRIPT_DIR/.pixi/envs/default"

export PYTHONPATH=""
export PROJ_DATA="$PIXI_ENV/share/proj"
export GDAL_DATA="$PIXI_ENV/share/gdal"
export LD_LIBRARY_PATH="$PIXI_ENV/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

exec "$PIXI_ENV/bin/python" -Xfrozen_modules=off -m ipykernel_launcher "$@"
