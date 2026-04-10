#!/usr/bin/env bash

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

margine_detect_runtime_flavor() {
  local flavor="${MARGINE_FLAVOR:-}"

  if [[ -z "$flavor" && -r /var/lib/margine/flavor ]]; then
    flavor="$(tr -d '[:space:]' < /var/lib/margine/flavor)"
  fi

  if [[ -z "$flavor" ]]; then
    flavor="$(margine_default_flavor)"
  fi

  flavor="${flavor,,}"
  if ! margine_validate_flavor "$flavor"; then
    flavor="$(margine_default_flavor)"
  fi

  printf '%s\n' "$flavor"
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

  margine_resolve_package_layer "$repo_root" "$flavor" "aur-baseline"
}

margine_resolve_aur_exceptions_manifest() {
  local repo_root="$1"
  local flavor="$2"

  margine_resolve_package_layer "$repo_root" "$flavor" "aur-exceptions"
}
