#!/bin/bash
# DevForge - WordPress Automatic Restore Script
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/wordpress/wordpress-restore.sh | bash -s backup_file.tar.gz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_FILE="$1"
RESTORE_PATH="/var/www/wordpress"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -z "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Uso: $0 caminho/do/backup.tar.gz${NC}"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Arquivo de backup não encontrado: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        DevForge - WordPress Automatic Restore Script            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"

# Verificar checksum
if [ -f "$BACKUP_FILE.sha256" ]; then
    echo -e "${BLUE}🔐 Verificando integridade do backup...${NC}"
    if sha256sum -c "$BACKUP_FILE.sha256" --status 2>/dev/null; then
        echo -e "${GREEN}✅ Checksum verificado com sucesso!${NC}"
    else
        echo -e "${RED}❌ Checksum inválido! O backup pode estar corrompido.${NC}"
        exit 1
    fi
fi

# Extrair backup
echo -e "${BLUE}📦 Extraindo backup...${NC}"
TEMP_DIR="/tmp/wordpress_restore_$TIMESTAMP"
mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Encontrar diretório do backup extraído
BACKUP_EXTRACTED=$(find "$TEMP_DIR" -type d -name "backup_*" | head -1)

if [ -z "$BACKUP_EXTRACTED" ]; then
    echo -e "${RED}❌ Estrutura de backup inválida${NC}"
    exit 1
fi

# Fazer backup do site atual
if [ -d "$RESTORE_PATH" ]; then
    echo -e "${YELLOW}⚠️  Site existente detectado. Criando backup...${NC}"
    sudo mv "$RESTORE_PATH" "${RESTORE_PATH}_backup_$TIMESTAMP"
fi

# Criar diretório WordPress
echo -e "${BLUE}📁 Criando diretório WordPress...${NC}"
sudo mkdir -p "$RESTORE_PATH/wp-content"

# Restaurar plugins
if [ -f "$BACKUP_EXTRACTED/plugins/plugins_*.zip" ]; then
    echo -e "${BLUE}🔌 Restaurando plugins...${NC}"
    PLUGIN_ZIP=$(ls "$BACKUP_EXTRACTED/plugins"/plugins_*.zip | head -1)
    sudo unzip -q "$PLUGIN_ZIP" -d "$RESTORE_PATH/wp-content/" 2>/dev/null
    echo -e "${GREEN}✅ Plugins restaurados${NC}"
fi

# Restaurar temas
if [ -f "$BACKUP_EXTRACTED/themes/themes_*.zip" ]; then
    echo -e "${BLUE}🎨 Restaurando temas...${NC}"
    THEME_ZIP=$(ls "$BACKUP_EXTRACTED/themes"/themes_*.zip | head -1)
    sudo unzip -q "$THEME_ZIP" -d "$RESTORE_PATH/wp-content/" 2>/dev/null
    echo -e "${GREEN}✅ Temas restaurados${NC}"
fi

# Restaurar uploads
if [ -f "$BACKUP_EXTRACTED/uploads/uploads_*.zip" ]; then
    echo -e "${BLUE}🖼️  Restaurando uploads...${NC}"
    UPLOAD_ZIP=$(ls "$BACKUP_EXTRACTED/uploads"/uploads_*.zip | head -1)
    sudo unzip -q "$UPLOAD_ZIP" -d "$RESTORE_PATH/wp-content/" 2>/dev/null
    echo -e "${GREEN}✅ Uploads restaurados${NC}"
fi

# Restaurar configuração
if [ -f "$BACKUP_EXTRACTED/config/wp-config_*.php" ]; then
    echo -e "${BLUE}⚙️  Restaurando configuração...${NC}"
    sudo cp "$BACKUP_EXTRACTED/config/wp-config_"*.php "$RESTORE_PATH/wp-config.php"
    echo -e "${YELLOW}⚠️  Edite o wp-config.php com suas credenciais do banco de dados!${NC}"
fi

# Restaurar banco de dados
DB_BACKUP=$(ls "$BACKUP_EXTRACTED/database"/wordpress_db_*.sql.gz 2>/dev/null | head -1)
if [ -f "$DB_BACKUP" ]; then
    echo -e "${BLUE}🗄️  Restaurando banco de dados...${NC}"
    echo -e "${YELLOW}Informe as credenciais do banco de dados:${NC}"
    read -p "Nome do banco: " DB_NAME
    read -p "Usuário: " DB_USER
    read -s -p "Senha: " DB_PASS
    echo ""
    read -p "Host [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    gunzip -c "$DB_BACKUP" | mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" 2>/dev/null
    echo -e "${GREEN}✅ Banco de dados restaurado!${NC}"
fi

# Ajustar permissões
echo -e "${BLUE}🔧 Ajustando permissões...${NC}"
sudo chown -R www-data:www-data "$RESTORE_PATH"
sudo chmod -R 755 "$RESTORE_PATH"
sudo chmod 600 "$RESTORE_PATH/wp-config.php"

# Limpar arquivos temporários
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Restauração concluída com sucesso!${NC}"
echo -e "${BLUE}🌐 Acesse seu site para verificar: http://localhost${NC}"