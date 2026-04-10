#!/usr/bin/env bash

# Backward-compatible shim.
# New code should source product-manifests.sh directly.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=product-manifests.sh
source "${script_dir}/product-manifests.sh"
