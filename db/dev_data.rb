
#
# users

u = User.new
u.name = "alice"
u.password = "alice"
u.save!

u = User.new
u.name = "bob"
u.password = "bob"
u.save!

u = User.new
u.name = "charly"
u.password = "charly"
u.save!

u = User.new
u.name = "admin"
u.password = "admin"
u.admin = true
u.save!

#
# groups

g = Group.new
g.name = "sales"
g.username = "alice"
g.save!

g = Group.new
g.name = "production"
g.username = "bob"
g.save!

g = Group.new
g.name = "production"
g.username = "charly"
g.save!

#
# stores

s = WiStore.new
s.name = "alpha"
s.regex = "alpha"
s.save!

s = WiStore.new
s.name = "bravo"
s.regex = "bravo"
s.save!

#s = WiStore.new
#s.name = "users"
#s.regex = "user_.*"
#s.save!
  #
  # now replaced by an implicit store participant
  # (see lib/densha/engine.rb)

#
# store_permissions

sp = StorePermission.new
sp.storename = "alpha"
sp.groupname = "sales"
sp.permission = "rwd"
sp.save!

sp = StorePermission.new
sp.storename = "bravo"
sp.groupname = "sales"
sp.permission = "rwd"
sp.save!

sp = StorePermission.new
sp.storename = "bravo"
sp.groupname = "production"
sp.permission = "rwd"
sp.save!

#
# launch_permissions

p = LaunchPermission.new
p.groupname = "" # for anybody
p.url = "/process_definitions/vacation_request_0.rb"
p.save!

p = LaunchPermission.new
p.groupname = "" # for anybody
p.url = "/process_definitions/simple_sequence_1.xml"
p.save!

p = LaunchPermission.new
p.groupname = "" # for anybody
p.url = "/process_definitions/simple_concurrence_1.rb"
p.save!

#p = LaunchPermission.new
#p.groupname = "" # for anybody
#p.url = "http://openwferu.rubyforge.org/svn/trunk/openwfe-ruby/examples/bigflow.rb"
#p.save!

