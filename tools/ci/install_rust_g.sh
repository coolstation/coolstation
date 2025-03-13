#!/bin/bash
set -euo pipefail

source buildByond.conf

cp /home/runner/work/coolstation/coolstation/tools/ci/librust_g.so ${BYOND_SYSTEM}/bin/librust_g.so
chmod +x ${BYOND_SYSTEM}/bin/librust_g.so
ldd ${BYOND_SYSTEM}/bin/librust_g.so
