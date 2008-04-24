
require 'fileutils'

#
# Bootstraps the development database for ruote-rest
#
#     rake bootstrap_db
#
task :bootstrap_db do

    db = "densha_development"
    db_admin_user = "root"

    sh 'mysql -u '+db_admin_user+' -p -e "drop database '+db+'"'
    sh 'mysql -u '+db_admin_user+' -p -e "create database '+db+' CHARACTER SET utf8 COLLATE utf8_general_ci"'

    #sh "rake db:migrate VERSION=-1"
    sh "rake db:migrate"

    FileUtils.rm_rf [ "work_test", "work_development" ]
    sh "rm log/*.log"
    sh "touch log/development.log"
end

