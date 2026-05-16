#!/bin/bash
# DevForge WordPress Installer (LEMP + WP-CLI)
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/wordpress/install-wordpress.sh | bash

set -e
SITE_PATH="/var/www/wordpress"
DB_NAME="wp_devforge"
DB_USER="wp_user"
DB_PASS=$(openssl rand -base64 24)

echo "🔧 Atualizando sistema e instalando Nginx, PHP 8.3, MariaDB, Redis..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx php8.3-fpm php8.3-mysql php8.3-curl php8.3-xml php8.3-zip php8.3-mbstring php8.3-gd php8.3-redis mariadb-server redis-server certbot python3-certbot-nginx

# Instalar WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Configurar banco de dados
sudo mysql <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Baixar WordPress
sudo mkdir -p $SITE_PATH
sudo chown -R $USER:www-data $SITE_PATH
cd $SITE_PATH
wp core download --locale=pt_BR --allow-root
wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS --locale=pt_BR --allow-root
wp core install --url="http://localhost" --title="DevForge WordPress" --admin_user="devforge_admin" --admin_password="DevForge@2025" --admin_email="admin@devforge.local" --allow-root

# Configurar Nginx
sudo tee /etc/nginx/sites-available/wordpress > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    root $SITE_PATH;
    index index.php;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
}
EOF
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo systemctl restart nginx php8.3-fpm

echo "✅ WordPress instalado com sucesso!"
echo "🔑 Acesse em: http://localhost"
echo "👤 Admin: devforge_admin | Senha: DevForge@2025"
echo "📄 Banco: $DB_NAME | Usuário: $DB_USER | Senha: $DB_PASS (salve!)"