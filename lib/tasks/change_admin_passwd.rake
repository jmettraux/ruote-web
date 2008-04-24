
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

