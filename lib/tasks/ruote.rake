
namespace :ruote do

  RUFUSES = %w{
    dollar eval lru mnemo scheduler verbs treechecker
  }.collect { |e| "rufus-#{e}" }

  #
  # do use either :install_workflow_engine either :install_dependency_gems
  # but not both
  #

  #
  # Installs under vendor/ the latest source of OpenWFEru (and required
  # subprojects).
  #
  task :install do

    FileUtils.mkdir "tmp" unless File.exists?("tmp")

    rm_r 'vendor/ruote'
    rm_r 'vendor/rufus'
    mkdir 'vendor' unless File.exist?('vendor')

    RUFUSES.each { |e| git_clone(e) }
    git_clone 'ruote'

    #sh "sudo gem install json_pure rogue_parser"
    #sh "sudo gem install rogue_parser"
  end

  def git_clone (elt)

    chdir 'tmp' do
      sh "git clone git://github.com/jmettraux/#{elt}.git"
    end
    cp_r "tmp/#{elt}/lib/*", 'vendor/'
    rm_r "tmp/#{elt}"
  end

  #
  # install OpenWFEru and its dependencies as gems
  #
  task :gem_install do

    GEMS = RUFUSES.dup

    GEMS << 'ruote'
    #GEMS << 'rogue_parser'

    sh "sudo gem install --no-rdoc --no-ri #{GEMS.join(' ')}"

    puts
    puts "installed gems  #{GEMS.join(' ')}"
    puts
  end
end

