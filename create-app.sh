#!/usr/bin/env bash
set -e

# Ayuda
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
Usage:
  laniakea-create-app [--dev] [--help]

Options:
  --dev       Ejecutar en desarrollo (sin compilar; usa ts-node)
  -h, --help  Muestra esta ayuda
EOF
  exit 0
fi

# URL de la plantilla (overrideable con env var)
TEMPLATE_URL="${TEMPLATE_URL:-https://github.com/aitorbernis/laniakea-app-template.git}"

# Desarrollo: lanza TS directamente
if [[ "$1" == "--dev" ]]; then
  shift
  exec npx ts-node "$(dirname "$0")/src/index.ts" "$@"
fi

# Producción: lanza JS compilado
exec node "$(dirname "$0")/dist/index.js" "$@"
