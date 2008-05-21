
require 'active_record'
require 'active_record/fixtures'

#
# Populates  the development database with the data found under db/dev_fixtures
#
#   rake populate_dev_db
#
task :populate_dev_db => :environment do

  ActiveRecord::Base.establish_connection :development

  Fixtures.create_fixtures(
    'db/dev_fixtures',
    [ 'groups', 'launch_permissions', 'store_permissions', 'users', 'wi_stores' ])

  puts
  puts "loaded #{User.find(:all).size} users"
  puts "loaded #{Group.find(:all).size} group memberships"
  puts "loaded #{WiStore.find(:all).size} workitem stores"
  puts "loaded #{StorePermission.find(:all).size} store permissions"
  puts "loaded #{LaunchPermission.find(:all).size} launch permissions"
  puts
end

