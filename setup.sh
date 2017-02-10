#!/bin/bash
/etc/init.d/ssh start
apt-get update
apt-get upgrade -y
apt-get install ruby ruby-dev digitemp libmysqlclient-dev
wget https://sqlite.org/snapshot/sqlite-snapshot-201702071351.tar.gz
tar xzf sqlite-snapshot-201702071351.tar.gz
cd sqlite-snapshot-201702071351/
CFLAGS="-Os -DSQLITE_ENABLE_COLUMN_METADATA=1" ./configure
make install

gem install sqlite3 mysql
