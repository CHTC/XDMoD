#!/bin/bash

SERVER_MEM_BYTES=$(($MYSQL_SERVER_MEM_GIGS * 1024 * 1024 * 1024))
export MYSQL_BUFFER_POOL_SIZE=$(($SERVER_MEM_BYTES / 2))
export MYSQL_LOG_FILE_SIZE=$(($MYSQL_BUFFER_POOL_SIZE / 4))

for file in $(cat /setup_and_scripts/config_files.txt); 
do 
    cat $file | envsubst "$(cat /setup_and_scripts/config_vars.txt)" > $file; 
done

do_setup_database="false"

if [ ! -d /var/lib/mysql/mysql ]; then
    mkdir /var/lib/mysql/mysql
    /usr/bin/mysql_install_db --skip-test-db
    chown -Rh mysql:mysql /var/lib/mysql/mysql
    do_setup_database="true"
fi

sed -i s/\$XDMOD_ADMIN_PASSPLAIN/$(cat $XDMOD_ADMIN_PASSWORD_PATH)/ /etc/xdmod/portal_settings.ini

chmod o-r $MYSQL_ROOT_PASS_PATH
chmod o-r $XDMOD_ADMIN_PASSWORD_PATH

supervisorctl start mysql

if [ "$do_setup_database" = "true" ]; then
    while ! mysqladmin ping  2>/dev/null;
    do
        echo "mysqld not up, waiting one (1) second";
        sleep 1;
    done

    mysql --password="" < /setup_and_scripts/xdmod.dump

    # TODO Reduce privileges for xdmod@localhost once I know which extra databases it needs access to
    mysql --password="" -Be "
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); 
    CREATE USER IF NOT EXISTS 'xdmod'@'localhost' identified by '$(cat $XDMOD_ADMIN_PASSWORD_PATH)'; 
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat $MYSQL_ROOT_PASS_PATH)'); 
    FLUSH PRIVILEGES; GRANT ALL PRIVILEGES ON * . * TO 'xdmod'@'localhost';"
    /setup_and_scripts/htcss_shred_ingest_script.sh
fi

supervisorctl start php-fpm-server-runner
httpd

# /etc/mail/make