#!/bin/bash

#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#for file in $(cat $SCRIPT_DIR/config_files.txt); do cat $file | envsubst "$(cat $SCRIPT_DIR/config_vars.txt)" > $file; done

sed -i s/\$XDMOD_ADMIN_PASSPLAIN/$(cat $XDMOD_ADMIN_PASSWORD_PATH)/ /etc/xdmod/portal_settings.ini

chmod o-r $MYSQL_ROOT_PASS_PATH
chmod o-r $XDMOD_ADMIN_PASSWORD_PATH

mysql --password="" -Be "SET PASSWORD FOR 'xdmod'@'localhost' = PASSWORD('$(cat $XDMOD_ADMIN_PASSWORD_PATH)'); SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat $MYSQL_ROOT_PASS_PATH)'); FLUSH PRIVILEGES;"

httpd

# /etc/mail/make