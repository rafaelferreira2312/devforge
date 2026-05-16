#!/bin/bash
# Hardening de segurança para WordPress

# 1. Proteger wp-config.php
echo "🔒 Protegendo wp-config.php..."
sudo chmod 600 /var/www/wordpress/wp-config.php

# 2. Bloquear acesso direto a arquivos sensíveis via .htaccess ou Nginx
sudo tee -a /etc/nginx/sites-available/wordpress > /dev/null <<EOF
location ~ /(wp-config.php|xmlrpc.php|wp-admin/install.php) {
    deny all;
    return 403;
}
EOF
sudo systemctl reload nginx

# 3. Gerar novas chaves de segurança (SALT)
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/wordpress/wp-config.php

# 4. Desabilitar edição de temas/plugins via admin
echo "define('DISALLOW_FILE_EDIT', true);" >> /var/www/wordpress/wp-config.php

echo "✅ Hardening aplicado com sucesso!"