#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TF_DIR="${REPO_ROOT}/infra/terraform"
TFVARS="${TF_DIR}/terraform.tfvars"
PLAN_FILE="${TF_DIR}/admin-cidr.tfplan"
PLAN_TMP="${PLAN_FILE}.tmp"
IP_URL="https://api.ipify.org"

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || die "curl is required."
command -v terraform >/dev/null 2>&1 || die "terraform is required."

[[ -f "${TFVARS}" ]] || die "Missing ${TFVARS}"

CURRENT_IP="$(
  curl -4 --fail --silent --show-error --max-time 10 "${IP_URL}" |
    tr -d '[:space:]'
)"

[[ "${CURRENT_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] ||
  die "Invalid IPv4 returned: ${CURRENT_IP}"

IFS='.' read -r -a OCTETS <<< "${CURRENT_IP}"

for OCTET in "${OCTETS[@]}"; do
  (( 10#${OCTET} <= 255 )) ||
    die "Invalid IPv4 returned: ${CURRENT_IP}"
done

MATCH_COUNT="$(
  grep -Ec '^[[:space:]]*admin_cidr[[:space:]]*=' "${TFVARS}" || true
)"

[[ "${MATCH_COUNT}" -eq 1 ]] ||
  die "Expected exactly one admin_cidr entry in terraform.tfvars."

OLD_CIDR="$(
  sed -nE \
    's/^[[:space:]]*admin_cidr[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' \
    "${TFVARS}"
)"

NEW_CIDR="${CURRENT_IP}/32"

printf '\nCurrent configured CIDR : %s\n' "${OLD_CIDR}"
printf 'Detected public CIDR   : %s\n\n' "${NEW_CIDR}"

if [[ "${OLD_CIDR}" != "${NEW_CIDR}" ]]; then
  sed -i \
    -E "s|^[[:space:]]*admin_cidr[[:space:]]*=.*$|admin_cidr = \"${NEW_CIDR}\"|" \
    "${TFVARS}"

  printf 'terraform.tfvars updated locally.\n\n'
else
  printf 'terraform.tfvars is already up to date.\n\n'
fi

printf '==> terraform fmt -check\n'
terraform -chdir="${TF_DIR}" fmt -check

printf '\n==> terraform validate\n'
terraform -chdir="${TF_DIR}" validate

printf '\n==> terraform plan\n'
rm -f "${PLAN_FILE}" "${PLAN_TMP}"
trap 'rm -f "${PLAN_TMP}"' EXIT
terraform -chdir="${TF_DIR}" plan -out="${PLAN_TMP}"
mv "${PLAN_TMP}" "${PLAN_FILE}"

printf '\n==> Saved plan review\n'
terraform -chdir="${TF_DIR}" show -no-color "${PLAN_FILE}"

printf '\n============================================================\n'
printf 'STOP: Azure has NOT been modified.\n'
printf 'Review the saved Terraform plan before running any apply.\n'
printf '============================================================\n'
