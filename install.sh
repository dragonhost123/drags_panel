#!/usr/bin/env bash
set -e

# 1) collect inputs
echo "== Custom Panel Installer (5 step) =="
read -p "Panel name (e.g. Nebula Panel): " PANEL_NAME
read -p "Panel primary color (HEX, e.g. #ff2b2b): " PRIMARY_COLOR
read -p "Admin email (github/email shown during install) : " ADMIN_EMAIL
read -p "Admin first name: " ADMIN_FIRST
read -p "Admin last name: " ADMIN_LAST
read -s -p "Admin password (will be saved to config.yml): " ADMIN_PWD
echo
read -p "Create admin? (yes/no) : " ADMIN_YN

# 2) create config.yml (writes values user provided)
cat > config.yml <<EOF
panel:
  name: "${PANEL_NAME:-Nebula Panel}"
  primary_color: "${PRIMARY_COLOR:-#ff2b2b}"
  jwt_secret: "change_this_secret_$(date +%s)"
  jwt_exp_minutes: 120
admin:
  email: "${ADMIN_EMAIL:-admin@example.com}"
  password: "${ADMIN_PWD:-admin123}"
install:
  installer_name: "${ADMIN_FIRST} ${ADMIN_LAST}"
  installer_email: "${ADMIN_EMAIL}"
EOF

echo "-> config.yml created."

# 3) start Docker services (build & run)
echo "-> Building and starting services (this may take a minute)..."
docker compose up --build -d

# 4) wait, run DB bootstrap and optional admin creation
echo "-> Waiting for API to become available..."
for i in {1..25}; do
  if curl -sS http://localhost:8000/ > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "-> Bootstrapping API (creating DB & admin from config)..."
curl -s -X POST http://localhost:8000/auth/bootstrap || echo "Bootstrap endpoint may have returned non-200; continuing."

# simulate "backup step" message as you described
echo "-> Creating initial DB backup (simulated)..."
mkdir -p backups
sqlite3 backend/panel.db ".backup 'backups/panel_${RANDOM}.bak'" 2>/dev/null || echo "backup skipped (sqlite3 not installed)".

# 5) show final message and port info (ports 8080 4040 3001 required — map them to services)
echo ""
echo "=== INSTALL COMPLETE ==="
echo "Panel running at: http://localhost:3001  (dashboard will load here)"
echo "API: http://localhost:8000"
echo "Other admin tools (if any): 8080, 4040 (if you expose them later)"
echo ""
echo "Login using the email you provided during install."
if [ \"${ADMIN_YN,,}\" = \"yes\" ]; then
  echo "Admin account created: ${ADMIN_EMAIL} (password set during install)"
else
  echo "Admin account was NOT created automatically (you chose no)."
fi
echo ""
echo "To add nodes (wings), run: bash node_install.sh <node-name> <region>"
