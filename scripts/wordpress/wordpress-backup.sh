#!/bin/bash
# DevForge - WordPress Complete Backup Script
# Versão: 1.0
# Descrição: Backup completo de banco de dados, plugins, temas, uploads, wp-config e estrutura do WordPress
# Autor: Rafael Ferreira - DevForge
# Data: $(date +%Y-%m-%d)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações padrão (edite conforme seu ambiente)
WP_PATH="${1:-/var/www/wordpress}"
DB_NAME="${2:-wp_devforge}"
DB_USER="${3:-wp_user}"
DB_PASS="${4:-}"
DB_HOST="${5:-localhost}"

# Configurações de backup
BACKUP_BASE_DIR="$HOME/devforge-backups/wordpress"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/backup_$TIMESTAMP"
RETENTION_DAYS=30

# Função para exibir uso do script
usage() {
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│              DevForge - WordPress Backup Script              │${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "${YELLOW}Uso:${NC}"
    echo "  $0 [caminho_wordpress] [nome_banco] [usuario_banco] [senha_banco] [host_banco]"
    echo ""
    echo -e "${YELLOW}Exemplo:${NC}"
    echo "  $0 /var/www/wordpress wp_db wp_user minha_senha localhost"
    echo ""
    echo -e "${YELLOW}Ou com valores padrão (edite o script):${NC}"
    echo "  $0"
    echo ""
}

# Função para verificar dependências
check_dependencies() {
    echo -e "${BLUE}🔍 Verificando dependências...${NC}"
    
    if ! command -v mysqldump &> /dev/null; then
        echo -e "${RED}❌ mysqldump não encontrado. Instale o mysql-client:${NC}"
        echo "   sudo apt install mysql-client"
        exit 1
    fi
    
    if ! command -v wp &> /dev/null; then
        echo -e "${YELLOW}⚠️  WP-CLI não encontrado. Instalando...${NC}"
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        sudo mv wp-cli.phar /usr/local/bin/wp
        echo -e "${GREEN}✅ WP-CLI instalado com sucesso!${NC}"
    fi
    
    if ! command -v zip &> /dev/null; then
        echo -e "${YELLOW}⚠️  zip não encontrado. Instalando...${NC}"
        sudo apt install -y zip unzip
    fi
    
    echo -e "${GREEN}✅ Todas as dependências estão OK!${NC}"
}

# Função para solicitar senha do banco se não fornecida
ask_db_password() {
    if [ -z "$DB_PASS" ]; then
        echo -e "${YELLOW}🔐 Informe a senha do banco de dados:${NC}"
        read -s DB_PASS
        echo ""
    fi
}

# Função para testar conexão com o banco
test_db_connection() {
    echo -e "${BLUE}📡 Testando conexão com o banco de dados...${NC}"
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" "$DB_NAME" &>/dev/null; then
        echo -e "${GREEN}✅ Conexão com o banco de dados bem-sucedida!${NC}"
        return 0
    else
        echo -e "${RED}❌ Falha na conexão com o banco de dados. Verifique as credenciais.${NC}"
        exit 1
    fi
}

# Função para criar estrutura de diretórios
create_directories() {
    echo -e "${BLUE}📁 Criando estrutura de diretórios...${NC}"
    mkdir -p "$BACKUP_DIR"/{database,plugins,themes,uploads,config,logs}
    mkdir -p "$BACKUP_BASE_DIR/logs"
    echo -e "${GREEN}✅ Estrutura criada em: $BACKUP_DIR${NC}"
}

# Função para backup do banco de dados
backup_database() {
    echo -e "${BLUE}🗄️  Realizando backup do banco de dados...${NC}"
    
    DB_BACKUP_FILE="$BACKUP_DIR/database/wordpress_db_$TIMESTAMP.sql"
    DB_COMPRESSED="$BACKUP_DIR/database/wordpress_db_$TIMESTAMP.sql.gz"
    
    # Backup usando mysqldump
    mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" \
        --single-transaction \
        --routines \
        --triggers \
        --add-drop-database \
        --hex-blob \
        --complete-insert \
        "$DB_NAME" > "$DB_BACKUP_FILE" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "$DB_BACKUP_FILE" ]; then
        gzip -f "$DB_BACKUP_FILE"
        DB_SIZE=$(du -h "$DB_COMPRESSED" | cut -f1)
        echo -e "${GREEN}✅ Banco de dados backupado com sucesso! Tamanho: $DB_SIZE${NC}"
        
        # Criar arquivo com metadados
        cat > "$BACKUP_DIR/database/metadata.txt" << EOF
Arquivo: wordpress_db_$TIMESTAMP.sql.gz
Tamanho: $DB_SIZE
Data: $(date)
Banco: $DB_NAME
Host: $DB_HOST
Tabelas: $(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME'" -sN 2>/dev/null || echo "N/A")
EOF
    else
        echo -e "${RED}❌ Falha no backup do banco de dados!${NC}"
        exit 1
    fi
}

# Função para backup de plugins
backup_plugins() {
    echo -e "${BLUE}🔌 Realizando backup dos plugins...${NC}"
    
    PLUGINS_DIR="$WP_PATH/wp-content/plugins"
    PLUGINS_BACKUP="$BACKUP_DIR/plugins/plugins_$TIMESTAMP.zip"
    
    if [ -d "$PLUGINS_DIR" ]; then
        # Obter lista de plugins ativos via WP-CLI
        if [ -f "$WP_PATH/wp-config.php" ]; then
            cd "$WP_PATH"
            wp plugin list --status=active --format=csv > "$BACKUP_DIR/plugins/active_plugins_$TIMESTAMP.csv" 2>/dev/null
            wp plugin list --status=inactive --format=csv > "$BACKUP_DIR/plugins/inactive_plugins_$TIMESTAMP.csv" 2>/dev/null
        fi
        
        # Compactar plugins
        zip -rq "$PLUGINS_BACKUP" "$PLUGINS_DIR" -x "*.git/*" "*.svn/*" "*.DS_Store"
        PLUGINS_SIZE=$(du -h "$PLUGINS_BACKUP" | cut -f1)
        echo -e "${GREEN}✅ Plugins backupados com sucesso! Tamanho: $PLUGINS_SIZE${NC}"
        
        # Salvar lista de plugins
        ls -la "$PLUGINS_DIR" > "$BACKUP_DIR/plugins/plugins_list_$TIMESTAMP.txt"
    else
        echo -e "${YELLOW}⚠️  Diretório de plugins não encontrado em: $PLUGINS_DIR${NC}"
    fi
}

# Função para backup de temas
backup_themes() {
    echo -e "${BLUE}🎨 Realizando backup dos temas...${NC}"
    
    THEMES_DIR="$WP_PATH/wp-content/themes"
    THEMES_BACKUP="$BACKUP_DIR/themes/themes_$TIMESTAMP.zip"
    ACTIVE_THEME=$(cd "$WP_PATH" && wp theme list --status=active --field=name 2>/dev/null || echo "unknown")
    
    if [ -d "$THEMES_DIR" ]; then
        # Salvar tema ativo
        echo "$ACTIVE_THEME" > "$BACKUP_DIR/themes/active_theme_$TIMESTAMP.txt"
        
        # Compactar temas
        zip -rq "$THEMES_BACKUP" "$THEMES_DIR" -x "*.git/*" "*.svn/*" "*.DS_Store"
        THEMES_SIZE=$(du -h "$THEMES_BACKUP" | cut -f1)
        echo -e "${GREEN}✅ Temas backupados com sucesso! Tema ativo: $ACTIVE_THEME, Tamanho: $THEMES_SIZE${NC}"
        
        # Salvar lista de temas
        ls -la "$THEMES_DIR" > "$BACKUP_DIR/themes/themes_list_$TIMESTAMP.txt"
    else
        echo -e "${YELLOW}⚠️  Diretório de temas não encontrado em: $THEMES_DIR${NC}"
    fi
}

# Função para backup de uploads (imagens, mídia)
backup_uploads() {
    echo -e "${BLUE}🖼️  Realizando backup dos uploads (imagens e mídia)...${NC}"
    
    UPLOADS_DIR="$WP_PATH/wp-content/uploads"
    UPLOADS_BACKUP="$BACKUP_DIR/uploads/uploads_$TIMESTAMP.zip"
    
    if [ -d "$UPLOADS_DIR" ]; then
        # Compactar uploads
        zip -rq "$UPLOADS_BACKUP" "$UPLOADS_DIR" -x "*.git/*" "*.DS_Store"
        UPLOADS_SIZE=$(du -h "$UPLOADS_BACKUP" | cut -f1)
        
        # Contar arquivos
        FILE_COUNT=$(find "$UPLOADS_DIR" -type f | wc -l)
        echo -e "${GREEN}✅ Uploads backupados com sucesso! Arquivos: $FILE_COUNT, Tamanho: $UPLOADS_SIZE${NC}"
        
        # Criar relatório de mídia via WP-CLI
        if [ -f "$WP_PATH/wp-config.php" ]; then
            cd "$WP_PATH"
            wp db query "SELECT COUNT(*) as total_attachments FROM wp_posts WHERE post_type='attachment'" \
                > "$BACKUP_DIR/uploads/media_count_$TIMESTAMP.txt" 2>/dev/null
        fi
    else
        echo -e "${YELLOW}⚠️  Diretório de uploads não encontrado em: $UPLOADS_DIR${NC}"
    fi
}

# Função para backup de arquivos de configuração
backup_config() {
    echo -e "${BLUE}⚙️  Realizando backup dos arquivos de configuração...${NC}"
    
    CONFIG_BACKUP="$BACKUP_DIR/config/config_files_$TIMESTAMP.zip"
    CONFIG_DIR="$BACKUP_DIR/config"
    
    # wp-config.php
    if [ -f "$WP_PATH/wp-config.php" ]; then
        cp "$WP_PATH/wp-config.php" "$CONFIG_DIR/wp-config_$TIMESTAMP.php"
        # Remover informações sensíveis para segurança
        sed -i 's/DB_PASSWORD.*/DB_PASSWORD, '\''[REDACTED]'\'');/g' "$CONFIG_DIR/wp-config_$TIMESTAMP.php"
        echo -e "${GREEN}✅ wp-config.php backupado (com dados sensíveis removidos)${NC}"
    fi
    
    # .htaccess
    if [ -f "$WP_PATH/.htaccess" ]; then
        cp "$WP_PATH/.htaccess" "$CONFIG_DIR/htaccess_$TIMESTAMP.txt"
        echo -e "${GREEN}✅ .htaccess backupado${NC}"
    fi
    
    # nginx/apache config se existir
    if [ -f "/etc/nginx/sites-available/wordpress" ]; then
        cp "/etc/nginx/sites-available/wordpress" "$CONFIG_DIR/nginx_wordpress_$TIMESTAMP.conf"
        echo -e "${GREEN}✅ Configuração Nginx backupada${NC}"
    fi
    
    if [ -f "/etc/apache2/sites-available/wordpress.conf" ]; then
        cp "/etc/apache2/sites-available/wordpress.conf" "$CONFIG_DIR/apache_wordpress_$TIMESTAMP.conf"
        echo -e "${GREEN}✅ Configuração Apache backupada${NC}"
    fi
    
    # Compactar arquivos de configuração
    if [ "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]; then
        zip -jq "$CONFIG_BACKUP" "$CONFIG_DIR"/* 2>/dev/null
        echo -e "${GREEN}✅ Arquivos de configuração compactados${NC}"
    fi
}

# Função para backup da estrutura do WordPress
backup_wordpress_structure() {
    echo -e "${BLUE}📦 Realizando backup da estrutura do WordPress (core files)...${NC}"
    
    # Salvar versão do WordPress
    if [ -f "$WP_PATH/wp-includes/version.php" ]; then
        WP_VERSION=$(grep "\$wp_version" "$WP_PATH/wp-includes/version.php" | cut -d "'" -f 2)
        echo "$WP_VERSION" > "$BACKUP_DIR/wordpress_version_$TIMESTAMP.txt"
        echo -e "${GREEN}✅ Versão do WordPress: $WP_VERSION${NC}"
    fi
    
    # Salvar lista de arquivos principais (sem conteúdo)
    find "$WP_PATH" -maxdepth 1 -type f -name "*.php" > "$BACKUP_DIR/wp_core_files_$TIMESTAMP.txt"
    
    # Verificar integridade dos arquivos core
    if command -v wp &> /dev/null && [ -f "$WP_PATH/wp-config.php" ]; then
        cd "$WP_PATH"
        wp core verify-checksums > "$BACKUP_DIR/core_integrity_$TIMESTAMP.txt" 2>/dev/null
        echo -e "${GREEN}✅ Integridade dos arquivos core verificada${NC}"
    fi
}

# Função para criar arquivo de manifesto do backup
create_manifest() {
    echo -e "${BLUE}📋 Criando manifesto do backup...${NC}"
    
    MANIFEST="$BACKUP_DIR/BACKUP_MANIFEST.txt"
    
    cat > "$MANIFEST" << EOF
╔═══════════════════════════════════════════════════════════════════════════════╗
║                       DevForge - WordPress Backup Manifest                     ║
╚═══════════════════════════════════════════════════════════════════════════════╝

📅 Data do backup: $(date)
🕐 Timestamp: $TIMESTAMP
💾 Tamanho total: $(du -sh "$BACKUP_DIR" | cut -f1)

📍 Localização do WordPress: $WP_PATH
🗄️  Banco de dados: $DB_NAME@$DB_HOST

────────────────────────────────────────────────────────────────────────────────
📁 Estrutura do backup:
────────────────────────────────────────────────────────────────────────────────

backup_$TIMESTAMP/
├── database/
│   ├── wordpress_db_$TIMESTAMP.sql.gz     # Banco de dados compactado
│   └── metadata.txt                        # Metadados do banco
├── plugins/
│   ├── plugins_$TIMESTAMP.zip              # Todos os plugins
│   ├── active_plugins_$TIMESTAMP.csv       # Plugins ativos
│   ├── inactive_plugins_$TIMESTAMP.csv     # Plugins inativos
│   └── plugins_list_$TIMESTAMP.txt         # Lista de diretórios
├── themes/
│   ├── themes_$TIMESTAMP.zip               # Todos os temas
│   ├── active_theme_$TIMESTAMP.txt         # Tema ativo
│   └── themes_list_$TIMESTAMP.txt          # Lista de diretórios
├── uploads/
│   ├── uploads_$TIMESTAMP.zip              # Imagens e mídia
│   └── media_count_$TIMESTAMP.txt          # Contagem de arquivos
├── config/
│   ├── config_files_$TIMESTAMP.zip         # Configurações
│   ├── wp-config_$TIMESTAMP.php            # Config WP (senha oculta)
│   ├── htaccess_$TIMESTAMP.txt             # Regras .htaccess
│   └── *.conf                              # Config Nginx/Apache
├── logs/
│   └── backup_$TIMESTAMP.log               # Log do processo
└── BACKUP_MANIFEST.txt                      # Este arquivo

────────────────────────────────────────────────────────────────────────────────
📊 Estatísticas do backup:
────────────────────────────────────────────────────────────────────────────────

$(if [ -f "$BACKUP_DIR/database/wordpress_db_$TIMESTAMP.sql.gz" ]; then echo "✓ Banco de dados: OK"; fi)
$(if [ -f "$BACKUP_DIR/plugins/plugins_$TIMESTAMP.zip" ]; then echo "✓ Plugins: OK"; fi)
$(if [ -f "$BACKUP_DIR/themes/themes_$TIMESTAMP.zip" ]; then echo "✓ Temas: OK"; fi)
$(if [ -f "$BACKUP_DIR/uploads/uploads_$TIMESTAMP.zip" ]; then echo "✓ Uploads: OK"; fi)
$(if [ -f "$BACKUP_DIR/config/config_files_$TIMESTAMP.zip" ]; then echo "✓ Configurações: OK"; fi)

EOF
    
    echo -e "${GREEN}✅ Manifesto criado em: $MANIFEST${NC}"
}

# Função para criar log do backup
create_log() {
    LOG_FILE="$BACKUP_DIR/logs/backup_$TIMESTAMP.log"
    
    {
        echo "[$(date)] Início do backup WordPress"
        echo "[$(date)] Diretório WordPress: $WP_PATH"
        echo "[$(date)] Banco de dados: $DB_NAME"
        echo "[$(date)] Backup criado em: $BACKUP_DIR"
        echo "[$(date)] Tamanho total: $(du -sh "$BACKUP_DIR" | cut -f1)"
        echo "[$(date)] Fim do backup - SUCESSO"
    } >> "$LOG_FILE"
    
    echo -e "${GREEN}✅ Log criado em: $LOG_FILE${NC}"
}

# Função para limpar backups antigos
cleanup_old_backups() {
    echo -e "${BLUE}🧹 Limpando backups com mais de $RETENTION_DAYS dias...${NC}"
    
    OLD_BACKUPS=$(find "$BACKUP_BASE_DIR" -type d -name "backup_*" -mtime +$RETENTION_DAYS 2>/dev/null)
    
    if [ -n "$OLD_BACKUPS" ]; then
        echo "$OLD_BACKUPS" | while read backup; do
            rm -rf "$backup"
            echo -e "${YELLOW}🗑️  Removido: $backup${NC}"
        done
        echo -e "${GREEN}✅ Limpeza concluída!${NC}"
    else
        echo -e "${GREEN}✅ Nenhum backup antigo para remover.${NC}"
    fi
}

# Função para compactar backup completo
compress_full_backup() {
    echo -e "${BLUE}🗜️  Compactando backup completo...${NC}"
    
    FINAL_BACKUP="$BACKUP_BASE_DIR/wordpress_full_backup_$TIMESTAMP.tar.gz"
    
    tar -czf "$FINAL_BACKUP" -C "$BACKUP_BASE_DIR" "backup_$TIMESTAMP"
    
    if [ -f "$FINAL_BACKUP" ]; then
        FINAL_SIZE=$(du -h "$FINAL_BACKUP" | cut -f1)
        echo -e "${GREEN}✅ Backup completo compactado: $FINAL_BACKUP${NC}"
        echo -e "${GREEN}📦 Tamanho final: $FINAL_SIZE${NC}"
        
        # Criar checksum para verificação de integridade
        sha256sum "$FINAL_BACKUP" > "$FINAL_BACKUP.sha256"
        echo -e "${GREEN}✅ Checksum SHA256 criado${NC}"
        
        # Limpar diretório descompactado
        rm -rf "$BACKUP_DIR"
    fi
}

# Função para exibir instruções de restauração
show_restore_instructions() {
    FINAL_BACKUP="$BACKUP_BASE_DIR/wordpress_full_backup_$TIMESTAMP.tar.gz"
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ✅ BACKUP CONCLUÍDO COM SUCESSO! ✅                          ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📦 Arquivo de backup:${NC}"
    echo "   $FINAL_BACKUP"
    echo ""
    echo -e "${BLUE}🔐 Checksum SHA256:${NC}"
    echo "   $(cat "$FINAL_BACKUP.sha256")"
    echo ""
    
    # Salvar instruções em arquivo
    RESTORE_INSTRUCTIONS="$BACKUP_BASE_DIR/RESTORE_INSTRUCTIONS_$TIMESTAMP.txt"
    
    cat > "$RESTORE_INSTRUCTIONS" << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    🔄 COMO RESTAURAR O WORDPRESS 🔄                            ║
╚═══════════════════════════════════════════════════════════════════════════════╝

📋 PRÉ-REQUISITOS ANTES DE RESTAURAR:
────────────────────────────────────────────────────────────────────────────────
1. Tenha o arquivo de backup (.tar.gz) e o checksum (.sha256)
2. Verifique a integridade do backup:
   sha256sum -c wordpress_full_backup_*.tar.gz.sha256

3. Certifique-se de ter os serviços instalados:
   - MySQL/MariaDB
   - PHP 8.3+ com extensões necessárias
   - Nginx/Apache
   - WP-CLI (recomendado)

────────────────────────────────────────────────────────────────────────────────
🔄 MÉTODO 1: RESTAURAÇÃO AUTOMÁTICA (RECOMENDADA)
────────────────────────────────────────────────────────────────────────────────

Execute o script de restauração automática:

curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/wordpress/wordpress-restore.sh | bash -s CAMINHO_DO_BACKUP.tar.gz

Exemplo:
curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/wordpress/wordpress-restore.sh | bash -s /home/user/wordpress_full_backup_20240101_120000.tar.gz

────────────────────────────────────────────────────────────────────────────────
🛠️ MÉTODO 2: RESTAURAÇÃO MANUAL
────────────────────────────────────────────────────────────────────────────────

1️⃣ Extraia o backup:
   tar -xzf wordpress_full_backup_*.tar.gz
   cd backup_*/

2️⃣ Restaure o banco de dados:
   gunzip -c database/wordpress_db_*.sql.gz | mysql -u SEU_USUARIO -p NOME_DO_BANCO

3️⃣ Restaure os arquivos do WordPress:
   # Faça backup do site atual (se existir)
   sudo mv /var/www/wordpress /var/www/wordpress.old.$(date +%Y%m%d)

   # Crie diretório limpo
   sudo mkdir -p /var/www/wordpress

   # Restaure plugins
   sudo unzip -q plugins/plugins_*.zip -d /var/www/wordpress/wp-content/

   # Restaure temas
   sudo unzip -q themes/themes_*.zip -d /var/www/wordpress/wp-content/

   # Restaure uploads
   sudo unzip -q uploads/uploads_*.zip -d /var/www/wordpress/wp-content/

   # Restaure configuração (edite com suas credenciais)
   sudo cp config/wp-config_*.php /var/www/wordpress/wp-config.php

4️⃣ Ajuste permissões:
   sudo chown -R www-data:www-data /var/www/wordpress
   sudo chmod -R 755 /var/www/wordpress
   sudo chmod 600 /var/www/wordpress/wp-config.php

5️⃣ Restaure configurações do servidor web (se necessário):
   sudo cp config/nginx_*.conf /etc/nginx/sites-available/wordpress
   # ou
   sudo cp config/apache_*.conf /etc/apache2/sites-available/wordpress.conf

6️⃣ Recarregue o servidor web:
   sudo systemctl reload nginx   # ou apache2

────────────────────────────────────────────────────────────────────────────────
✅ VERIFICAÇÃO PÓS-RESTAURAÇÃO
────────────────────────────────────────────────────────────────────────────────

Execute o diagnóstico automático para verificar se tudo está funcionando:

wp core version --allow-root && wp plugin list --status=active --allow-root && wp db check --allow-root

────────────────────────────────────────────────────────────────────────────────
⚠️ IMPORTANTE - SEGURANÇA
────────────────────────────────────────────────────────────────────────────────

1. Após restaurar, troque as senhas do banco de dados e do admin WordPress
2. Verifique se o arquivo wp-config.php tem as configurações corretas do seu ambiente
3. Atualize os salts do WordPress (https://api.wordpress.org/secret-key/1.1/salt/)
4. Limpe o cache do navegador e do plugin de cache (se houver)

────────────────────────────────────────────────────────────────────────────────
🆘 SUPORTE
────────────────────────────────────────────────────────────────────────────────

Se encontrar problemas durante a restauração:
📧 Email: rafaelferreira2312@gmail.com
📱 WhatsApp: (21) 97160-4248
💻 GitHub: https://github.com/rafaelferreira2312/devforge

EOF

    echo -e "${BLUE}📄 Instruções de restauração salvas em:${NC}"
    echo "   $RESTORE_INSTRUCTIONS"
    echo ""
    echo -e "${YELLOW}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🔐 GUARDE ESTAS INFORMAÇÕES EM LOCAL SEGURO! 🔐${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Mostrar resumo na tela
    cat "$RESTORE_INSTRUCTIONS"
}

# Função para notificar via webhook (opcional)
send_notification() {
    # Se quiser integrar com Discord/Slack/Telegram, adicione aqui
    echo -e "${BLUE}📢 Backup concluído em: $(date)${NC}"
}

# ==================== EXECUÇÃO PRINCIPAL ====================

main() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║     DevForge - WordPress Complete Backup Script v1.0           ║"
    echo "║     Desenvolvido para a comunidade DevForge                    ║"
    echo "║     https://github.com/rafaelferreira2312/devforge            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Verificar se ajuda foi solicitada
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        usage
        exit 0
    fi
    
    # Validar WordPress path
    if [ ! -d "$WP_PATH" ]; then
        echo -e "${RED}❌ Diretório WordPress não encontrado: $WP_PATH${NC}"
        echo -e "${YELLOW}💡 Use: $0 /caminho/para/seu/wordpress${NC}"
        exit 1
    fi
    
    if [ ! -f "$WP_PATH/wp-config.php" ]; then
        echo -e "${RED}❌ wp-config.php não encontrado em: $WP_PATH${NC}"
        echo -e "${YELLOW}💡 Certifique-se de que o caminho está correto${NC}"
        exit 1
    fi
    
    # Executar backup
    check_dependencies
    ask_db_password
    test_db_connection
    create_directories
    backup_database
    backup_plugins
    backup_themes
    backup_uploads
    backup_config
    backup_wordpress_structure
    create_manifest
    create_log
    compress_full_backup
    cleanup_old_backups
    show_restore_instructions
    send_notification
    
    echo -e "${GREEN}✅ Backup concluído com sucesso!${NC}"
}

# Executar função principal com todos os argumentos
main "$@"