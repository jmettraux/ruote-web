
= ruote-web

"ruote-web" is a Ruby on Rails application wrapping the Ruote OpenWFEru workflow and BPM engine. It's also called "densha" sometimes.


== how to install it

(assumes you're using MySQL on a Unix system)

    sudo gem install -y json_pure atom-tools

    mkdir ruote-web
    git clone git://github.com/jmettraux/ruote-web.git

    cd ruote-web
    rake rails:freeze:edge TAG=rel_2-0-2
    rake install_workflow_engine
    rake bootstrap_db

The last step (bootstrap_db) assumes that your database admin user is named "root" (and it will ask for the password of that user two times).

