#!/bin/bash

chown -R mysql:mysql /var/lib/mysql
/etc/init.d/mysql restart
/usr/bin/mysql -u root -p$MYSQL_ROOT_PASSWORD -e "$(cat /root/mysql-bootstrap/bootstrap.sql | sed "s/<%STAKEPOOL_MYSQL_DB_PASSWORD%>/$STAKEPOOL_MYSQL_DB_PASSWORD/g")"
/etc/init.d/mysql stop
/usr/bin/mysqld_safe
