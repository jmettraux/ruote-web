
namespace :data do

  #
  # Changes the admin password
  #
  #     rake change_admin_passwd PASS=newpass
  #
  task :change_admin_passwd => :environment do

    pass = ARGV.find do |arg|
        arg.match(/^PASS=.*/)
    end

    pass = pass[5..-1]

    u = User.find_by_name "admin"
    u.password = pass
    u.save!
  end


  require 'active_record'
  require 'active_record/fixtures'

  #
  # Populates the development database with the data found under db/dev_fixtures
  #
  #   rake data:populate
  #
  task :populate => :environment do

    ActiveRecord::Base.establish_connection :development

    Fixtures.create_fixtures(
      'db/dev_fixtures',
      %w{ groups launch_permissions store_permissions users wi_stores })

    puts
    puts "loaded #{User.find(:all).size} users"
    puts "loaded #{Group.find(:all).size} group memberships"
    puts "loaded #{WiStore.find(:all).size} workitem stores"
    puts "loaded #{StorePermission.find(:all).size} store permissions"
    puts "loaded #{LaunchPermission.find(:all).size} launch permissions"
    puts
  end

  #
  # Bootstraps the development database for ruote-web
  #
  #   rake data:bootstrap
  #
  task :bootstrap do

    db = 'densha_development'
    db_admin_user = 'root'
    db_user = 'densha'

    sh "mysql -u #{db_admin_user} -p -e \"drop database if exists #{db}\""
    sh "mysql -u #{db_admin_user} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""
    sh "mysql -u #{db_admin_user} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

    sh 'rake db:migrate'

    rm_rf [ 'work_test', 'work_development' ]
    sh 'rm log/*.log'
    touch 'log/development.log'
  end
end

