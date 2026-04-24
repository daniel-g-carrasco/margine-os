#!/usr/bin/env bash

margine_default_product() {
  printf 'margine-public\n'
}

margine_default_flavor() {
  printf 'arch\n'
}

margine_validate_flavor() {
  case "${1:-}" in
    arch|cachyos)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

margine_resolve_product_manifest() {
  local repo_root="$1"
  local product="${2:-}"
  local manifest="${repo_root}/products/${product}.toml"

  [[ -n "$product" ]] || return 1
  [[ -f "$manifest" ]] || return 1
  printf '%s\n' "$manifest"
}

margine_validate_product() {
  local repo_root="$1"
  local product="${2:-}"

  margine_resolve_product_manifest "$repo_root" "$product" >/dev/null
}

margine_product_field() {
  local manifest="$1"
  local field="$2"
  local default_value="${3:-}"

  python3 - "$manifest" "$field" "$default_value" <<'PY'
import pathlib
import sys

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    import tomli as tomllib

manifest_path = pathlib.Path(sys.argv[1])
field = sys.argv[2]
default_value = sys.argv[3]

data = {}
if manifest_path.is_file():
    with manifest_path.open("rb") as handle:
        data = tomllib.load(handle)

value = data.get(field, default_value)

if isinstance(value, bool):
    print("true" if value else "false")
elif isinstance(value, list):
    print(",".join(str(item) for item in value))
else:
    print(value)
PY
}

margine_product_list_field() {
  local manifest="$1"
  local field="$2"

  python3 - "$manifest" "$field" <<'PY'
import pathlib
import sys

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    import tomli as tomllib

manifest_path = pathlib.Path(sys.argv[1])
field = sys.argv[2]

data = {}
if manifest_path.is_file():
    with manifest_path.open("rb") as handle:
        data = tomllib.load(handle)

value = data.get(field, [])

if isinstance(value, list):
    for item in value:
        print(item)
elif value not in (None, ""):
    print(value)
PY
}

margine_detect_runtime_product() {
  local repo_root="$1"
  local product="${MARGINE_PRODUCT:-}"

  if [[ -z "$product" && -r /var/lib/margine/product ]]; then
    product="$(tr -d '[:space:]' < /var/lib/margine/product)"
  fi

  if [[ -z "$product" ]]; then
    product="$(margine_default_product)"
  fi

  product="${product,,}"
  if ! margine_validate_product "$repo_root" "$product"; then
    product="$(margine_default_product)"
  fi

  printf '%s\n' "$product"
}

margine_product_flavor() {
  local repo_root="$1"
  local product="$2"
  local manifest=""
  local flavor=""

  manifest="$(margine_resolve_product_manifest "$repo_root" "$product")" || return 1
  flavor="$(margine_product_field "$manifest" "flavor" "$(margine_default_flavor)")"
  flavor="${flavor,,}"

  if ! margine_validate_flavor "$flavor"; then
    flavor="$(margine_default_flavor)"
  fi

  printf '%s\n' "$flavor"
}

margine_product_extra_package_layers() {
  local repo_root="$1"
  local product="$2"
  local manifest=""

  manifest="$(margine_resolve_product_manifest "$repo_root" "$product")" || return 1
  margine_product_list_field "$manifest" "extra_package_layers"
}

margine_product_extra_provisioners() {
  local repo_root="$1"
  local product="$2"
  local manifest=""

  manifest="$(margine_resolve_product_manifest "$repo_root" "$product")" || return 1
  margine_product_list_field "$manifest" "extra_provisioners"
}

margine_kernel_image_default() {
  local kernel_package="${1:-}"

  [[ -n "$kernel_package" ]] || return 1
  printf '/boot/vmlinuz-%s\n' "$kernel_package"
}

margine_mkinitcpio_preset_name_default() {
  local kernel_package="${1:-}"

  [[ -n "$kernel_package" ]] || return 1
  printf '%s\n' "$kernel_package"
}

margine_detect_runtime_flavor() {
  local repo_root="$1"
  local flavor="${MARGINE_FLAVOR:-}"
  local product=""

  if [[ -z "$flavor" && -r /var/lib/margine/flavor ]]; then
    flavor="$(tr -d '[:space:]' < /var/lib/margine/flavor)"
  fi

  if [[ -z "$flavor" ]]; then
    product="$(margine_detect_runtime_product "$repo_root")"
    flavor="$(margine_product_flavor "$repo_root" "$product")"
  fi

  flavor="${flavor,,}"
  if ! margine_validate_flavor "$flavor"; then
    flavor="$(margine_default_flavor)"
  fi

  printf '%s\n' "$flavor"
}

margine_emit_product_context() {
  local repo_root="$1"
  local requested_product="${2:-}"
  local requested_flavor="${3:-}"
  local product=""
  local manifest=""
  local flavor=""
  local product_name=""
  local base_distribution=""
  local visibility=""
  local redistributable=""
  local kernel_package=""
  local kernel_headers_package=""
  local kernel_image=""
  local mkinitcpio_preset_name=""

  if [[ -n "$requested_product" ]]; then
    product="${requested_product,,}"
  else
    product="$(margine_detect_runtime_product "$repo_root")"
  fi

  margine_validate_product "$repo_root" "$product" || return 1
  manifest="$(margine_resolve_product_manifest "$repo_root" "$product")"

  if [[ -n "$requested_flavor" ]]; then
    flavor="${requested_flavor,,}"
  else
    flavor="$(margine_product_field "$manifest" "flavor" "$(margine_default_flavor)")"
  fi

  margine_validate_flavor "$flavor" || return 1

  product_name="$(margine_product_field "$manifest" "name" "$product")"
  base_distribution="$(margine_product_field "$manifest" "base_distribution" "arch")"
  visibility="$(margine_product_field "$manifest" "visibility" "public")"
  redistributable="$(margine_product_field "$manifest" "redistributable" "true")"
  kernel_package="$(margine_product_field "$manifest" "kernel_package" "")"
  kernel_headers_package="$(margine_product_field "$manifest" "kernel_headers_package" "")"
  kernel_image="$(margine_product_field "$manifest" "kernel_image" "")"
  mkinitcpio_preset_name="$(margine_product_field "$manifest" "mkinitcpio_preset_name" "")"

  if [[ -z "$kernel_image" && -n "$kernel_package" ]]; then
    kernel_image="$(margine_kernel_image_default "$kernel_package")"
  fi

  if [[ -z "$mkinitcpio_preset_name" && -n "$kernel_package" ]]; then
    mkinitcpio_preset_name="$(margine_mkinitcpio_preset_name_default "$kernel_package")"
  fi

  printf 'product=%q\n' "$product"
  printf 'product_manifest=%q\n' "$manifest"
  printf 'product_name=%q\n' "$product_name"
  printf 'product_base_distribution=%q\n' "$base_distribution"
  printf 'product_visibility=%q\n' "$visibility"
  printf 'product_redistributable=%q\n' "$redistributable"
  printf 'product_kernel_package=%q\n' "$kernel_package"
  printf 'product_kernel_headers_package=%q\n' "$kernel_headers_package"
  printf 'product_kernel_image=%q\n' "$kernel_image"
  printf 'product_mkinitcpio_preset_name=%q\n' "$mkinitcpio_preset_name"
  printf 'flavor=%q\n' "$flavor"
}

margine_resolve_package_layer() {
  local repo_root="$1"
  local flavor="$2"
  local layer="$3"
  local override="${repo_root}/manifests/flavors/${flavor}/packages/${layer}.txt"
  local common="${repo_root}/manifests/packages/${layer}.txt"

  if [[ -f "$override" ]]; then
    printf '%s\n' "$override"
    return 0
  fi

  if [[ -f "$common" ]]; then
    printf '%s\n' "$common"
    return 0
  fi

  return 1
}

margine_detect_hardware_package_layers() {
  local repo_root="$1"
  local flavor="$2"
  local cpu_vendor=""
  local dmi_vendor=""
  local dmi_product=""
  local pci_device=""
  local pci_class=""
  local pci_vendor=""
  local -A layers=()
  local -a ordered_layers=()
  local layer=""

  add_layer() {
    local candidate="$1"

    [[ -n "$candidate" ]] || return 0
    [[ -n "${layers[$candidate]+x}" ]] && return 0
    margine_resolve_package_layer "$repo_root" "$flavor" "$candidate" >/dev/null 2>&1 || return 0
    layers["$candidate"]=1
    ordered_layers+=("$candidate")
  }

  cpu_vendor="$(awk -F: '/vendor_id/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
  case "$cpu_vendor" in
    AuthenticAMD)
      add_layer hardware-amd-cpu
      ;;
    GenuineIntel)
      add_layer hardware-intel-cpu
      ;;
  esac

  for pci_device in /sys/bus/pci/devices/*; do
    [[ -r "${pci_device}/class" && -r "${pci_device}/vendor" ]] || continue
    pci_class="$(<"${pci_device}/class")"
    [[ "$pci_class" == 0x03* ]] || continue
    pci_vendor="$(<"${pci_device}/vendor")"

    case "$pci_vendor" in
      0x1002)
        add_layer hardware-amd-graphics
        ;;
      0x8086)
        add_layer hardware-intel-graphics
        ;;
      0x10de)
        add_layer hardware-nvidia-open-graphics
        ;;
    esac
  done

  dmi_vendor="$(cat /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null || true)"
  dmi_product="$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || true)"
  if [[ "$dmi_vendor" == "Framework" && "$dmi_product" == Laptop\ 13* ]]; then
    add_layer hardware-framework13
  fi

  for layer in "${ordered_layers[@]}"; do
    printf '%s\n' "$layer"
  done
}

margine_resolve_aur_layer() {
  local repo_root="$1"
  local flavor="$2"
  local layer="$3"
  local override="${repo_root}/manifests/flavors/${flavor}/aur/${layer}.txt"
  local common="${repo_root}/manifests/aur/${layer}.txt"

  if [[ -f "$override" ]]; then
    printf '%s\n' "$override"
    return 0
  fi

  if [[ -f "$common" ]]; then
    printf '%s\n' "$common"
    return 0
  fi

  case "$layer" in
    aur-baseline|aur-exceptions)
      margine_resolve_package_layer "$repo_root" "$flavor" "$layer"
      return $?
      ;;
  esac

  return 1
}

margine_resolve_flatpaks_manifest() {
  local repo_root="$1"
  local flavor="$2"
  local override="${repo_root}/manifests/flavors/${flavor}/flatpaks/apps.txt"
  local common="${repo_root}/manifests/flatpaks/apps.txt"

  if [[ -f "$override" ]]; then
    printf '%s\n' "$override"
    return 0
  fi

  if [[ -f "$common" ]]; then
    printf '%s\n' "$common"
    return 0
  fi

  return 1
}

margine_resolve_aur_baseline_manifest() {
  local repo_root="$1"
  local flavor="$2"

  margine_resolve_aur_layer "$repo_root" "$flavor" "aur-baseline"
}

margine_resolve_aur_exceptions_manifest() {
  local repo_root="$1"
  local flavor="$2"

  margine_resolve_aur_layer "$repo_root" "$flavor" "aur-exceptions"
}
