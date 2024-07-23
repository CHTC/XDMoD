FROM hub.opensciencegrid.org/opensciencegrid/software-base:23-el8-release

RUN yum install -y vim gettext

RUN dnf module -y reset nodejs
RUN dnf module -y install nodejs:16

RUN dnf install -y https://github.com/ubccr/xdmod/releases/download/v10.5.0-1.0/xdmod-10.5.0-1.0.el8.noarch.rpm

RUN yum install -y mariadb-server sendmail libreoffice chromium-headless php-fpm

# Copy in CHTC Slurm repo for 23.x Slurm build, and install
COPY ./configuration_files/slurm.repo /etc/yum.repos.d/slurm.repo
RUN yum install -y slurm

COPY ./configuration_files/mysql-confs/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN /usr/libexec/mysql-prepare-db-dir mysql mysql
COPY ./mysql /var/lib/mysql/
RUN chown -Rh mysql:mysql /var/lib/mysql/
RUN chmod g-w /run

# Create supervisord confs for required daemons
COPY ./configuration_files/supervisord-confs/mysqld.conf /etc/supervisord.d/mysqld.conf
COPY ./configuration_files/supervisord-confs/apache-server-runner.conf /etc/supervisord.d/apache-server-runner.conf
COPY ./configuration_files/supervisord-confs/php-fpm-runner.conf /etc/supervisord.d/php-fpm-runner.conf
COPY ./configuration_files/supervisord-confs/munge.conf /etc/supervisord.d/munge.conf

# Load in xdmod configurations
COPY ./xdmod /etc/xdmod/
RUN chown -Rh xdmod:xdmod /etc/xdmod
RUN chmod -R o=rx /etc/xdmod
RUN chmod -R o=rx /usr/share/xdmod/

# Set ability to change date.timezone in php.ini with envvars
COPY ./configuration_files/php-confs/php.ini /etc/php.ini

# Enable HTTPS in Apache webserver configuration
COPY ./configuration_files/apache-confs/httpd.conf /etc/httpd/conf/httpd.conf
COPY ./configuration_files/apache-confs/xdmod.conf /etc/httpd/conf.d/xdmod.conf
COPY ./configuration_files/apache-confs/ssl.conf /etc/httpd/conf.d/ssl.conf
COPY ./configuration_files/apache-confs/php.conf /etc/httpd/conf.d/php.conf
COPY ./configuration_files/apache-confs/php-fpm.conf /etc/php-fpm.conf
COPY ./configuration_files/apache-confs/php-fpm-pool.conf /etc/php-fpm.d/apache.conf
RUN mkdir -p /run/php-fpm

# Remove default php-fpm conf file.
RUN rm -f /etc/php-fpm.d/www.conf

# Load in setup script and supervisor conf for running the script
COPY ./setup_config /setup_config
COPY ./configuration_files/supervisord-confs/setup.conf /etc/supervisord.d/setup.conf

# Copy in sendmail configuration file
COPY ./configuration_files/sendmail-confs/sendmail.mc /etc/mail/sendmail.mc

# Set Default envvars for configs
ENV XDMOD_ADMIN_FIRSTNAME='XDMOD_ADMIN_FIRSTNAME'
ENV XDMOD_ADMIN_LASTNAME='XDMOD_ADMIN_LASTNAME'
ENV XDMOD_ADMIN_EMAIL='XDMOD_ADMIN_EMAIL'
ENV XDMOD_ADMIN_USERNAME='XDMOD_ADMIN_USERNAME'
ENV XDMOD_ADMIN_PASSWORD_PATH='XDMOD_ADMIN_PASSWORD_PATH'
ENV APACHE_HOSTNAME='localhost'
ENV APACHE_PORT='443'
ENV APACHE_TLSCERT_PATH='APACHE_TLSCERT_PATH'
ENV APACHE_TLSKEY_PATH='APACHE_TLSKEY_PATH'
ENV MYSQL_ROOT_PASS_PATH='MYSQL_ROOT_PASS_PATH'
ENV MYSQL_SERVERMEM='MYSQL_SERVERMEM'
ENV PHP_TIMEZONE='America/Chicago'
ENV TOTAL_SERVER_MEM_GIGS=10