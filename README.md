# 🚀 Nebula Hosting Panel

Custom hosting panel with **nebula theme**, **red animated dashboard**, **login/register system**, **player manager**, **plugin installer**, **multi-node support** (India, Germany, Saudi, Arabic), and **admin panel**.

---

## 📌 Requirements
- Ubuntu 20.04 / 22.04 (Recommended)
- Docker & Docker Compose
- Git

---

## ⚙️ Install Panel (5 Commands)

Run these codes one by one:

```bash
# 1. Update system
sudo apt update -y && sudo apt upgrade -y

# 2. Install dependencies
sudo apt install -y git curl docker.io docker-compose

# 3. Clone panel
git clone https://github.com/YOUR-USERNAME/YOUR-PANEL.git
cd YOUR-PANEL

# 4. Run installer (creates DB, backups, config)
bash install.sh

# 5. Start panel
docker-compose up -d
