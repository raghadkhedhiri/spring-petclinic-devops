#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Image GHCR manquante}"
ARCHIVE="${2:?Chemin de la sortie manquant}"

if [[ ! "$IMAGE" =~ ^ghcr\.io/[a-z0-9._-]+/petclinic-app:[0-9a-f]{40}$ ]]; then
  echo "ERREUR - image GHCR ou SHA invalide" >&2
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/manifests"

for FILE in \
  namespace.yaml \
  petclinic-configmap.yaml \
  petclinic-deployment.yaml \
  petclinic-service.yaml \
  petclinic-metrics-service.yaml \
  petclinic-ingress.yaml
do
  cp "k8s/base/$FILE" "$WORKDIR/manifests/$FILE"
done

DEPLOYMENT="$WORKDIR/manifests/petclinic-deployment.yaml"

test "$(grep -Ec "^[[:space:]]*image:[[:space:]]+" "$DEPLOYMENT")" -eq 1

sed -i -E \
  "s|^([[:space:]]*image:[[:space:]]*).*|\1${IMAGE}|" \
  "$DEPLOYMENT"

grep -Fq "image: ${IMAGE}" "$DEPLOYMENT"

tar -czf "$ARCHIVE" -C "$WORKDIR" manifests

echo "OK - six manifests préparés"
