#!/bin/bash
/etc/init.d/ssh start
apt-get update
apt-get upgrade -y
apt-get install ruby ruby-dev digitemp libpq-dev -y

gem install pg

digitemp_DS9097U  -s /dev/ttyUSB0 -i