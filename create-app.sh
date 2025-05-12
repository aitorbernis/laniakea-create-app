#!/usr/bin/env bash
set -e

# Valores por defecto
TEMPLATE_URL="git@github.com:aitorbernis/laniakea-app-template.git"
DEFAULT_HTTP_PORT=3000
DEFAULT_ADMIN_PORT=3001
DEFAULT_BACKEND_PORT=8000
DEFAULT_DB_PORT=3306
DEFAULT_DB_ROOT_PASS="rootpass"
DEFAULT_DB_NAME="name"
DEFAULT_DB_USER="user"
DEFAULT_DB_PASS="pass"

function usage() {
  cat <<EOF
Uso interactivo: te preguntará todos los datos necesarios.

Ejecuta sin parámetros y responde a los prompts.
Opciones:
  -h, --help   Muestra esta ayuda
EOF
  exit 0
}

# Soporte -h/--help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

echo "🔧 Bienvenido al generador de proyectos"

# 1) Nombre del proyecto
read -p "Nombre del proyecto: " NAME
[[ -z "$NAME" ]] && { echo "❌ Debes indicar un nombre para el proyecto."; exit 1; }

# 2) URL del template
read -p "URL del repo plantilla [${TEMPLATE_URL}]: " input
TEMPLATE_URL="${input:-$TEMPLATE_URL}"

# 3) Puertos frontend, admin y backend
read -p "Puerto HTTP frontend [${DEFAULT_HTTP_PORT}]: " input
HTTP_PORT="${input:-$DEFAULT_HTTP_PORT}"
read -p "Puerto HTTP admin    [${DEFAULT_ADMIN_PORT}]: " input
ADMIN_PORT="${input:-$DEFAULT_ADMIN_PORT}"
read -p "Puerto backend       [${DEFAULT_BACKEND_PORT}]: " input
BACKEND_PORT="${input:-$DEFAULT_BACKEND_PORT}"

# 4) Configuración DB
read -p "Puerto MariaDB       [${DEFAULT_DB_PORT}]: " input
DB_PORT="${input:-$DEFAULT_DB_PORT}"
read -p "Root DB password     [${DEFAULT_DB_ROOT_PASS}]: " input
DB_ROOT_PASSWORD="${input:-$DEFAULT_DB_ROOT_PASS}"
read -p "DB name              [${DEFAULT_DB_NAME}]: " input
DB_NAME="${input:-$DEFAULT_DB_NAME}"
read -p "DB user              [${DEFAULT_DB_USER}]: " input
DB_USER="${input:-$DEFAULT_DB_USER}"
read -p "DB password          [${DEFAULT_DB_PASS}]: " input
DB_PASSWORD="${input:-$DEFAULT_DB_PASS}"

echo
# 5) Clona y limpia el repo

echo "🚀 Clonando '${NAME}' desde ${TEMPLATE_URL}..."
git clone --depth 1 "${TEMPLATE_URL}" "${NAME}"
cd "${NAME}"
rm -rf .git

echo "✓ Repositorio limpio."

# 6) Genera root .env para Docker-Compose

echo "📝 Generando root .env para Docker-Compose…"
cat > .env <<EOF
# Puertos
HTTP_PORT=${HTTP_PORT}
ADMIN_PORT=${ADMIN_PORT}
BACKEND_PORT=${BACKEND_PORT}
DB_PORT=${DB_PORT}

# Credenciales MariaDB
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
EOF

echo "✓ Root .env creado."

# 7) Genera backend/.env para Prisma

echo "📝 Generando backend/.env…"
cat > backend/.env <<EOF
DATABASE_URL="mysql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}"
PORT=${BACKEND_PORT}
EOF

# 8) Genera frontend/admin .env.local

echo "📝 Generando frontend/.env.local…"
cat > frontend/.env.local <<EOF
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOF

echo "📝 Generando admin/.env.local…"
cat > admin/.env.local <<EOF
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOF

# 9) Personaliza docker-compose.yml

echo "🛠 Personalizando docker-compose.yml…"
export HTTP_PORT ADMIN_PORT BACKEND_PORT DB_PORT
export DB_ROOT_PASSWORD DB_NAME DB_USER DB_PASSWORD
envsubst '
$HTTP_PORT 
$ADMIN_PORT 
$BACKEND_PORT 
$DB_PORT 
$DB_ROOT_PASSWORD 
$DB_NAME 
$DB_USER 
$DB_PASSWORD' \
< docker-compose.yml > tmp-dc.yml && mv tmp-dc.yml docker-compose.yml

echo "✓ docker-compose.yml actualizado."

# 10) Elimina contenedores y volumen previo

echo "🗑  Borrando contenedores y volumen anterior…"
docker-compose down -v || true

# 11) Levanta contenedores Docker

echo "🚀 Levantando contenedores (docker-compose up -d --build)…"
docker-compose up -d --build

# 12) Instala deps en root

echo "🔧 Instalando dependencias del monorepo…"
npm install

# 13) Prepara backend para Prisma
echo "🔧 Preparando backend para Prisma…"
cd backend
npm install

# Genera Prisma Client y aplica el esquema sin migraciones
npx prisma generate
npx prisma db push
cd ..

# 14) Mensaje final
echo
echo "✅ Proyecto '${NAME}' creado exitosamente!"
echo "  • Frontend: http://localhost:${HTTP_PORT}"
echo "  • Admin:    http://localhost:${ADMIN_PORT}"
echo "  • API:      http://localhost:${BACKEND_PORT}"
echo
echo "Para ver la base vacía: cd ${NAME}/backend && npx prisma studio"
