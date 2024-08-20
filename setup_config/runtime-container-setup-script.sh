#!/bin/sh

sed -i s/\$XDMOD_ADMIN_PASSPLAIN/$(cat $XDMOD_ADMIN_PASSWORD_PATH)/ /etc/xdmod/portal_settings.ini

chmod o-r $MYSQL_ROOT_PASS_PATH
chmod o-r $XDMOD_ADMIN_PASSWORD_PATH

supervisorctl start mysql

while [ ! $(mysqladmin ping 2>/dev/null) ];
do
        sleep 1;
done

mysql --password="" -Be "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); CREATE user 'xdmod'@'localhost' identified by '$(cat $XDMOD_ADMIN_PASSWORD_PATH)'; SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$(cat $MYSQL_ROOT_PASS_PATH)'); FLUSH PRIVILEGES;"

#supervisorctl start php-fpm-server-runner
# httpd

# /etc/mail/make