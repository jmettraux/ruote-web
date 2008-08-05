
require 'fileutils'

#
# Bootstraps the development database for ruote-web
#
#   rake bootstrap_dev_db
#
task :bootstrap_dev_db do

  db = 'densha_development'
  db_admin_user = 'root'
  db_user = 'densha'

  sh "mysql -u #{db_admin_user} -p -e \"drop database if exists #{db}\""
  sh "mysql -u #{db_admin_user} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""
  sh "mysql -u #{db_admin_user} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

  #sh "rake db:migrate VERSION=-1"
  sh "rake db:migrate"

  FileUtils.rm_rf [ "work_test", "work_development" ]
  sh "rm log/*.log"
  sh "touch log/development.log"
end

