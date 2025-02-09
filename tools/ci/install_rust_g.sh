#!/bin/bash
set -euo pipefail

source buildByond.conf

wget -O ${BYOND_SYSTEM}/bin/librust_g.so "https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x ${BYOND_SYSTEM}/bin/librust_g.so
ldd ${BYOND_SYSTEM}/bin/librust_g.so
