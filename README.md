#Drupal on Vagrant#

##Usage##

1.   Clone this repo
1.   Pull in the submodules
     `$ git submodule init
     $  git submodule update`
1.   Bring up Vagrant
     `$ vagrant up`


##Aims##

* Provide a standardised development instance
* Integrate with our workflow (git, drush make)
* Provide simple utilities for developers (drush quick drupal)
* Provide simple testing for code quality (doxygen, validators, test/jenkins)


##Installing Drush##

* ~~Squid for caching make installs~~ (Drush 5.x does this internally)
* bzr and svn because quick drupal likes it
* Sqlite3 so that quick drupal can make dbs easily
* Mail for mailing messages

$ sudo apt-get install bzr svn sqlite3 php-pear php5-cgi php5-sqlite squid sendmail
$ sudo pear channel-discover pear.drush.org
$ sudo pear install drush/drush-6
$ drush selfupdate

###Quick Drupal###
$ drush  -y qd test-panels panels

###Download and enable a module###

###Make from a new profile (via GitHub)###

Takes a git repo name or path as an argument

###Rebuild features###

Named or all features

###Check make manifest for missing modules###

*   Modules in contrib are in the .make and .info files
*   Modules in custom are in the .info file
*	Could use pm-list --type=module --status=enabled (but its slow)

###Connect to staging and pull in a sanitised database###
