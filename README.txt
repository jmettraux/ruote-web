
= ruote-web

"ruote" is the nickname of the OpenWFEru Ruby workflow and BPM engine.

    http://openwferu.rubyforge.org


"ruote-web" is a Ruby on Rails application wrapping the Ruote OpenWFEru workflow and BPM engine. It's also called "densha" sometimes.


== online demo

    http://difference.openwfe.org:3000


== how to install it

(assumes you're using MySQL on a Unix system)

    sudo gem install -y json_pure atom-tools

    git clone git://github.com/jmettraux/ruote-web.git

    cd ruote-web
    rake install_workflow_engine
    rake bootstrap_db


The last step (bootstrap_db) assumes that your database admin user is named "root" (and it will ask for the password of that user two times).

If you want to install the dependencies (rufus and ruote) as ruby gems, you can run

    rake gem_install_workflow_engine

instead of "rake install_workflow_engine"


if Rails on your system is not a 2.0.x one, you might want to freeze a local Rails :

    cd ruote-web && rake rails:freeze:edge TAG=rel_2-0-2

That will install Rails 2.0.2 under ruote-web/vendor/rails


== run it

    cd ruote-web
    ruby script/server

And point your browser to http://localhost:3000 (then login as admin/admin or bob/bob)


== update it

    cd ruote-web && git pull

to update the engine and its dependencies, simply pull out fresh copies by doing :

    cd ruote-web && rake install_workflow_engine


== feedback

user mailing list :        http://groups.google.com/group/openwferu-users
developers mailing list :  http://groups.google.com/group/openwferu-dev

issue tracker :            http://rubyforge.org/tracker/?atid=10023&group_id=2609&func=browse


== author

John Mettraux, jmettraux@gmail.com 
http://jmettraux.wordpress.com

credits : http://github.com/jmettraux/ruote-web/tree/master/CREDITS.txt


== license

BSD

