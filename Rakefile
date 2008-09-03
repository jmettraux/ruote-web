# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

#require 'vlad'
#Vlad.load 'config/deploy.rb'


desc "packages a 'distribution' of ruote-rest"
task :distribute do

  pk = "ruote-web-0.9.19"
  dest = "pkg/#{pk}"

  rm_r(dest) if File.exist?(dest)

  mkdir_p dest
  files = %w{
    Rakefile config lib public test app script db vendor
  }
  %w{ LICENSE CREDITS README CHANGELOG }.each { |t| files << "#{t}.txt" }
  files.each do |src|
    cp_r src, dest
    puts "copied #{src}"
  end

  chdir dest do
    sh 'rake ruote:get_from_github'
    mkdir 'log'
  end
  chdir 'pkg' do
    sh "jar cvf #{pk}.zip #{pk}"
  end
end

