#!/usr/bin/env bash
set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: bash node_install.sh <node-name> <region>"
  echo "Example: bash node_install.sh india-1 India"
  exit 1
fi

NODE_NAME="$1"
NODE_REGION="$2"
PANEL_URL="${PANEL_URL:-http://localhost:8000}"

echo "== Node installer for: $NODE_NAME (region: $NODE_REGION) =="

# 1) Create node folder and basic config
echo "1) Creating node folder..."
mkdir -p nodes/$NODE_NAME
cat > nodes/$NODE_NAME/node.conf <<EOF
name: ${NODE_NAME}
region: ${NODE_REGION}
panel_url: ${PANEL_URL}
token: TEMP_TOKEN_PLACEHOLDER
EOF

# 2) Generate registration token from panel (call panel API)
echo "2) Requesting node token from panel..."
RET=$(curl -s -X POST "${PANEL_URL}/nodes/request-token" -H "Content-Type: application/json" -d "{\"name\":\"${NODE_NAME}\",\"region\":\"${NODE_REGION}\"}")

TOKEN=$(echo "$RET" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
if [ -z "$TOKEN" ]; then
  echo "Warning: couldn't retrieve token, using local generated one."
  TOKEN="local-$(date +%s)-$RANDOM"
fi

# write token to node config
sed -i "s/TEMP_TOKEN_PLACEHOLDER/${TOKEN}/" nodes/$NODE_NAME/node.conf

# 3) Start node agent (simple simulated agent run; in real world you'd deploy wings here)
echo "3) Starting node agent (simulated)..."
cat > nodes/$NODE_NAME/agent.sh <<'AGENT'
#!/usr/bin/env bash
echo "Node agent starting..."
sleep 1
echo "Registering with panel..."
sleep 1
echo "Node active (simulated). Listening for jobs..."
while true; do sleep 3600; done
AGENT
chmod +x nodes/$NODE_NAME/agent.sh
nohup bash nodes/$NODE_NAME/agent.sh >/dev/null 2>&1 &

echo ""
echo "Node ${NODE_NAME} installed and started (simulated)."
echo "Panel URL: ${PANEL_URL}"
echo "Node token: ${TOKEN}"
echo "To view nodes in the panel visit: http://localhost:3001/admin/nodes (if you add a UI page)."
