#!/bin/bash
#Script de backup via dump para mysql/mariadb
cd /tmp
VALIDADE_DIAS=5
MYSQL_LISTAR_BANCOS="--skip-column-names -E"
MYSQL_USUARIO=""
MYSQL_SENHA=""
MYSQL_PORTA="3306"
MYSQL_OPCOES_BACKUP="--complete-insert --dump-date --routines --triggers --single-transaction"
DIRETORIO_BACKUP="/backup_mysql"
DATA_ATUAL_FORMATO=$(date +%d%m%Y-%H%M)
DIRETORIO_ATUAL_BACKUP="$DIRETORIO_BACKUP/$DATA_ATUAL_FORMATO/"
#Rotinas de remocao de conteudo antigo
for remocao_diretorio in $(find $DIRETORIO_BACKUP/* -type d -mtime +$VALIDADE_DIAS | grep -v .gz | xargs); do
        test -d $remocao_diretorio && rm -rf $remocao_diretorio
done
if test ! -e $DIRETORIO_BACKUP; then
    echo "Criando diretorio principal de backups $DIRETORIO_BACKUP"
    mkdir $DIRETORIO_BACKUP
fi
if test -e $DIRETORIO_ATUAL_BACKUP; then
    echo "diretorio de backup $DIRETORIO_ATUAL_BACKUP ja existe, o backup nao sera realizado"
exit 1
else
    mkdir $DIRETORIO_ATUAL_BACKUP
fi
for bancos_backup in $(mysql -u "$MYSQL_USUARIO" -p"$MYSQL_SENHA" -P"$MYSQL_PORTA" $MYSQL_LISTAR_BANCOS -e "show databases" | grep -v "^*" | grep -iv "performance_schema" | grep -iv "information_schema" | xargs); do
    mysqldump -u "$MYSQL_USUARIO" -p"$MYSQL_SENHA" -P"$MYSQL_PORTA" $MYSQL_OPCOES_BACKUP $bancos_backup | gzip > $DIRETORIO_ATUAL_BACKUP$bancos_backup$DATA_ATUAL_FORMATO.gz ;
done