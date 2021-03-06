#Drupal on Vagrant#

##Usage##

1.   Clone this repo
     `$ git clone git@github.com:Laudanum/vagrant-puppet-drupal`
1.   Pull in the submodules
     `$ cd vagrant-puppet-drupal;
      $ git submodule init
      $ git submodule update`
1.   Create the sites directory
     `$ mkdir ../sites`
1.	 Optionally create your own github ssh keys (they'll be copied into the VM)
	 `$ mkdir ../ssh-config && ssh-keygen -f ../ssh-config/github.rsa`
1.   Bring up Vagrant
     `$ vagrant up`

##Troubleshooting##
1.  Missing ruby libs (stdlib)
    Apache::vhosts can't find validate_re
    https://github.com/knowshantanu/puppetmod-uabopennebula/issues/11
    Comment out that line in modules/apache/manifests/vhosts.pp
1.  Permission issues running drush or apahce
    Remount /srv/www rewrite and nobody:nobody
    `umount /srv/www && mount -t vboxsf -o umask=000,dmode=777,fmode=666,gid=99,uid=99 sites /srv/www`

##Updating submodules##
1.  Init submodules & update
      `$ git submodule init
      $ git submodule update`
1.  Change directory to submodule
    `$ cd puppet/modules/apache`
1.  Switch branch to master (submodules branch)
    `$ git checkout master`
1.  Pull in changes
    `$ git pull`
1.  Change directory to parent project
    `$ cd ../..`
1.  Commit
    `$ git commit -am "Update apache submodule."`
1.  Restore any pre pull fixes you may have
    https://github.com/knowshantanu/puppetmod-uabopennebula/issues/11

##Aims##

* Provide a standardised development instance
* Integrate with our workflow (git, drush make)
* Provide simple utilities for developers (drush quick drupal)
* Provide simple testing for code quality (doxygen, validators, test/jenkins)

##Extending this VM##
*   Add a submodule
    `$ git submodule add git@github.com:rafaelfelix/puppet-pear puppet/modules/pear`


##Sources##
https://github.com/drupalboxes/drupal-puppet/tree/master/drupal

##TODO##
*   ~~Add github to known_hosts~~
*   ~~Solve github ssh keys (share with host, copy to host, push vagrants to github)~~
*   Add hosts to /etc/hosts (on Vagrant guest)
*   Look at Vagrant hosts plugin (for host?)
*   ~~Enable mod_php~~ added package (unnecessary?) and php.conf
*   ~~Install lynx~~
*   Write Vagrant plugin for git / drush.
*   settings.php for Drupal isn't working
`$databases = array (
  'default' =>
  array (
    'default' =>
    array (
      'database' => 'spacetimeconcerto.com_local',
      'username' => 'vagrant',
      'password' => 'vagrant',
      'host' => 'localhost',
      'port' => '',
      'driver' => 'mysql',
      'prefix' => '',
    ),
  ),
);
`
*   ~~Install php-mysql~~
*   AllowOverride all for our vhosts (where is this coming from? apache via drupal?)
*   ~~Permissions on `files` are bad~~ changed owner to apache in vagrant file
*   Drush aliases (for sync from staging or production and sanitise)
*   ~~.ssh/config is missing~~
*  	install unzip (for drush)

##Installing Drush##

* ~~Squid for caching make installs~~ (Drush 5.x does this internally)
* bzr and svn because quick drupal likes it
* Sqlite3 so that quick drupal can make dbs easily (php-pdo)
* Mail for mailing messages

$ sudo apt-get install bzr ~~svn~~ subversion ~~sqlite3~~ php-pear php5-cgi ~~php5-sqlite~~ php-pdo ~~squid~~ sendmail
$ sudo pear channel-discover pear.drush.org
$ sudo pear install drush/drush-6
$ drush selfupdate


###Quick Drupal###
Probably not useful. Requires permission to install httpserver and would run within vagrant. Would require extra port forards too.
`Drush needs to download a library from https://github.com/youngj/httpserver/tarball/41dd2b7160b8cbd25d7b5383e3ffc6d8a9a59478 in order to function, and the attempt to download this file automatically failed because you do[error]`
$ drush -y qd test-panels panels

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
