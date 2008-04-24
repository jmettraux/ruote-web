
RUFUS_GEMS = %w{ dollar eval lru mnemo scheduler verbs }

#
# do use either :install_workflow_engine either :install_dependency_gems
# but not both
#

#
# Installs under vendor/ the latest source of OpenWFEru (and required 
# subprojects).
#
task :install_workflow_engine do

  SVNS = RUFUS_GEMS.collect do |e|
    "http://rufus.rubyforge.org/svn/trunk/#{e}/lib/rufus"
  end

  SVNS << "http://openwferu.rubyforge.org/svn/trunk/openwfe-ruby/lib/openwfe"

  SVNS.each do |s|

    target = s.split("/").last
    #`svn co #{s} vendor/#{target}`
    sh "svn co #{s} vendor/#{target}"
    sh "rm -fR vendor/rufus/.svn"
  end
end

#
# install OpenWFEru and its dependencies as gems
#
task :gem_install_workflow_engine do

  GEMS = RUFUS_GEMS.collect do |e|
    "rufus-#{e}"
  end

  GEMS << "openwferu"
  GEMS << "openwferu-extras"

  GEMS << "json_pure"
  GEMS << "xml_simple"

  sh "sudo gem install -y #{GEMS.join(' ')}"

  puts
  puts "installed gems  #{GEMS.join(' ')}"
  puts
end

