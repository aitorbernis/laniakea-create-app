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
Usage:
  laniakea-create-app

Interactively generate a new full-stack project.
Options:
  -h, --help   Show this help message
EOF
  exit 0
}

# Soporte -h/--help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

echo "🔧 Welcome to the Laniakea project generator"

# 1) Project name
read -p "Project name: " NAME
[[ -z "$NAME" ]] && { echo "❌ You must provide a project name."; exit 1; }

# 2) Ports
read -p "HTTP port for frontend [${DEFAULT_HTTP_PORT}]: " input
HTTP_PORT="${input:-$DEFAULT_HTTP_PORT}"
read -p "HTTP port for admin    [${DEFAULT_ADMIN_PORT}]: " input
ADMIN_PORT="${input:-$DEFAULT_ADMIN_PORT}"
read -p "Port for backend       [${DEFAULT_BACKEND_PORT}]: " input
BACKEND_PORT="${input:-$DEFAULT_BACKEND_PORT}"

# 3) Database settings
read -p "MariaDB port           [${DEFAULT_DB_PORT}]: " input
DB_PORT="${input:-$DEFAULT_DB_PORT}"
read -p "Root DB password       [${DEFAULT_DB_ROOT_PASS}]: " input
DB_ROOT_PASSWORD="${input:-$DEFAULT_DB_ROOT_PASS}"
read -p "DB name                [${DEFAULT_DB_NAME}]: " input
DB_NAME="${input:-$DEFAULT_DB_NAME}"
read -p "DB user                [${DEFAULT_DB_USER}]: " input
DB_USER="${input:-$DEFAULT_DB_USER}"
read -p "DB password            [${DEFAULT_DB_PASS}]: " input
DB_PASSWORD="${input:-$DEFAULT_DB_PASS}"

echo
# 4) Clone & clean
echo "🚀 Cloning '${NAME}' from ${TEMPLATE_URL}..."
git clone --depth 1 "${TEMPLATE_URL}" "${NAME}"
cd "${NAME}"
rm -rf .git
echo "✓ Template cloned and cleaned."

# 5) Rename package.json "name" field
if [[ -f package.json ]]; then
  echo "📝 Updating package.json name to '$NAME'..."
  # macOS vs Linux sed differences
  if sed --version >/dev/null 2>&1; then
    sed -i "s/\"name\": *\"[^\"]*\"/\"name\": \"$NAME\"/" package.json
  else
    sed -i '' "s/\"name\": *\"[^\"]*\"/\"name\": \"$NAME\"/" package.json
  fi
fi

# 6) Generate root .env
echo "📝 Generating root .env for Docker Compose..."
cat > .env <<EOF
HTTP_PORT=${HTTP_PORT}
ADMIN_PORT=${ADMIN_PORT}
BACKEND_PORT=${BACKEND_PORT}
DB_PORT=${DB_PORT}

DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
EOF
echo "✓ .env created."

# 7) Generate service envs
echo "📝 Generating backend/.env..."
cat > backend/.env <<EOF
DATABASE_URL="mysql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}"
PORT=${BACKEND_PORT}
EOF

echo "📝 Generating frontend/.env.local..."
cat > frontend/.env.local <<EOF
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOF

echo "📝 Generating admin/.env.local..."
cat > admin/.env.local <<EOF
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOF

# 8) Customize docker-compose.yml
echo "🛠 Customizing docker-compose.yml..."
export HTTP_PORT ADMIN_PORT BACKEND_PORT DB_PORT \
       DB_ROOT_PASSWORD DB_NAME DB_USER DB_PASSWORD
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
echo "✓ docker-compose.yml updated."

# 9) Clean previous Docker state
echo "🗑 Removing old containers and volumes..."
docker-compose down -v || true

# 10) Start Docker
echo "🚀 Starting Docker services..."
docker-compose up -d --build

# 11) Install monorepo deps
echo "🔧 Installing monorepo dependencies..."
npm install

# 12) Prepare backend for Prisma
echo "🔧 Preparing backend (Prisma)..."
cd backend
npm install
npx prisma generate
npx prisma db push


echo
echo "✅ Project '${NAME}' created successfully!"
echo "  • Frontend: http://localhost:${HTTP_PORT}"
echo "  • Admin:    http://localhost:${ADMIN_PORT}"
echo "  • API:      http://localhost:${BACKEND_PORT}"
echo
echo "👉 Next steps:"
echo "   cd ${NAME}"
echo "   npm run dev    # to start everything"
echo "   npm run stop   # to stop the stack"
echo "   cd backend && npx prisma studio    # inspect your empty DB"
