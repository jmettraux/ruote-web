
#
# Put your openwferu participants here.
#
# see examples of participant at
#     http://openwferu.rubyforge.org/participants.html
#
# and also at
#     http://viewvc.rubyforge.mmmultiworks.com/cgi/viewvc.cgi/trunk/openwfe-ruby/examples/engine_template.rb?root=openwferu&view=markup
#


#
# A stupid "toto" participant, simply outputs a message to the console (if any)
# each time it receives a workitem.
#
$openwferu_engine.register_participant "toto" do |workitem|

  puts
  puts "toto received a workitem"
  puts "and immediately sent it back to the engine" #implicitely
  puts
end

#require 'openwfe/extras/participants/basecamp_participants'
#$openwferu_engine.register_participant(
#    "john", 
#    OpenWFE::Extras::BasecampParticipant.new(
#        :host => ENV['BC_HOST'],
#        :username => ENV['BC_USERNAME'],
#        :password => ENV['BC_PASSWORD'],
#        #:project_id => ENV['BC_PROJECT_ID'],
#        :todo_list_id => ENV['BC_TODO_LIST_ID'],
#        :responsible_party_id => ENV['BC_RESPONSIBLE_PARTY_ID'],
#        :ssl => false))

#
# Note that store participant are registered in config/openwferu_engine.rb
#

#
# When all the participants have been registered, reschedule temporal
# expressions left from previous run (restart).
#
$openwferu_engine.reschedule

