#!/bin/bash

mysql \
    -u root -p \
    -e "drop database densha_development"

mysql \
    -u root -p \
    -e "create database densha_development CHARACTER SET utf8 COLLATE utf8_general_ci"
#mysql \
#    -u root -p \
#    -e "create database densha_test CHARACTER SET utf8 COLLATE utf8_general_ci;"

#rake db:migrate VERSION=-1
rake db:migrate

rm -fR work_test work_development

rm log/*.log
touch log/development.log

