
$LOAD_PATH << "~/ruote/lib"
$LOAD_PATH << "~/rufus/rufus-scheduler/lib"

require 'rubygems'

#
# the workflow engine
#

require 'densha/engine' # lib/densha/engine.rb

require 'openwfe/extras/misc/activityfeed' # gem 'openwferu-extras'


#
# checking for initial data

if $0 =~ /script\/server/ and RAILS_ENV == 'development'

  users = User.find(:all)

  if users.size < 1
      puts
      puts
      puts " * no initial data *"
      puts
      puts "consider running"
      puts
      puts "    rake bootstrap_dev_db"
      puts "    rake populate_dev_db"
      puts
      puts
  end
end

#
# instantiates the workflow engine

#require 'logger'

ac = {}

ac[:work_directory] = "work_#{RAILS_ENV}"
  #
  # where the workflow engine stores its rundata
  #
  # (note that workitems are stored via ActiveRecord as soon as they are
  #  assigned to an ActiveStoreParticipant)

ac[:logger] = Logger.new "log/openwferu_#{RAILS_ENV}.log", 10, 1024000
ac[:logger].level = (RAILS_ENV == 'production') ? Logger::INFO : Logger::DEBUG

ac[:ruby_eval_allowed] = true
  #
  # the 'reval' expression and ${r:xxx} notation are allowed

ac[:dynamic_eval_allowed] = true
  #
  # the 'eval' expression is allowed


$openwferu_engine = Densha::Engine.new ac

$openwferu_engine.reload_store_participants
  #
  # reload now.
  #
  # will register a participant per workitem store


#
# init the Atom activity feed
#
# you're better off turning that off as it currently lets anybody have a look
# at the activity

$openwferu_engine.init_service(
  'activityFeedService', OpenWFE::Extras::ActivityFeedService)


if Module.constants.include?('Mongrel') then
  #
  # graceful shutdown for Mongrel by Torsten Schoenebaum

  class Mongrel::HttpServer
    alias :old_graceful_shutdown :graceful_shutdown
    def graceful_shutdown
      $openwferu_engine.stop
      old_graceful_shutdown
    end
  end
else

  at_exit do
    #
    # make sure to stop the workflow engine when 'densha' terminates

    $openwferu_engine.stop
  end
end

#
# add your participants there

require 'config/openwferu_participants'

