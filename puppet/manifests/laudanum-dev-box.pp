# support quickdrupal
# $ sudo apt-get install php5-cgi
# $ sudo chown vagrant /usr/share/php/drush/lib

$dev_domains = [ 
  "spacetimeconcerto.com", 
  "sturtassociates.com.au", 
  "artlib.com.au", 
  "scanlines.net", 
  "supanova.org.au", 
  "d7.supanova.org.au", 
  "janus.supanova.org.au", 
  "matteozingales.com", 
  "saccid.com", 
  "subedit.me",
  "turpincrawford.com",
  "newsouthbooks.com.au",
] 
# on bruno:
# didn't install mysql-client mysql-server php5-mysql php5-gd pear drush
# need to install ruby, compass and zen
# sudo apt-get install ruby libxml2-dev libxslt1-dev
# sudo gem install compass
# sudo gem install zen
# ERROR:  Error installing zen:
#  zen requires Ruby version >= 1.9.2.
# still always need to sudo pear uninstall drush/drush on every boot

$dev_domains = [ "supanova.org.au", "d7.supanova.org.au", "spacetimeconcerto.com", "sturtassociates.com.au", "artlib.com.au", "cashmereandkaye.com", "scanlines.net", "ailiesnow.com",  "saccid.com"] 

define create_drupal_site {
# apache::vhosts provides this
#  file {"/srv/www/${name}":
#      ensure => directory,
#      mode   => 644,
#  }

  file {"/srv/www/${name}/backup":
    ensure => directory,
    mode   => 777,
  }

  file {"/srv/www/${name}/content":
    ensure => directory,
    mode   => 777,
  }

# cant' use vagrant (as mysql complains about duplicate users)
#  mysql::db { "${name}_local":
#    user     => "${name}",
#    password => "${name}",
#    host     => 'localhost',
#    grant    => ['all'],
#  }
  database { "${name}_local":
      ensure  => 'present',
      charset => 'utf8',
  }
  database_grant { "vagrant@localhost/${name}_local":
    privileges => ['all'] ,
  }
  
# @TODO currently drupal::site overwrites settings. thats bad
  drupal::site { "${name}":
    databases => { 
      "default" => { 
        "default" => { 
          database  => "${name}_local", 
          username  => 'vagrant', 
          password => 'vagrant', 
          host => 'localhost', 
          port => '', 
          driver => 'mysql', 
          prefix => ''
        }
      }
    },
    drupal_root => "/srv/www/${name}/local",
    conf        => {},
    url         => "local.${name}",
    aliases     => [],
  }
}

class laudanum_dev_box {

  case $operatingsystem {
    ubuntu: { 
      exec { "apt_get_update":
        command => "/usr/bin/apt-get update",
        require => Exec["networking_restart"],
      }
    }
  }

  user { "apache": 
    ensure => "present", 
  }
  user { "puppet": 
    ensure => "present", 
  }
  case $operatingsystem {
      centos: { $git = "git" }
      redhat: { $git = "git" }
      debian: { $git = "git-core" }
      ubuntu: { $git = "git-core" }
      default: { fail("Unrecognized operating system for webserver") }
      # "fail" is a function. We'll get to those later.
  }
  package { $git:
    ensure => "present",
  }
  package { "wget":
    ensure => "present",
  }
  package { "lynx":
    ensure => "present",
  }

  host { "host-local.${dev_domains[0]}":
    ensure => "present",
    ip     => "127.0.0.1",
    host_aliases => [ "local.${dev_domains[0]}", "localhost", "vagrant-centos-6.localdomain"],
  }

# Create necessary parent directories.
  file {["/srv", "/srv/www"]:
      ensure => directory,
#      mode => 644,
  }

  class {'apache': }
  class {'apache::mod::php': }
  case $operatingsystem {
    centos: { 
      package { "mod-php": # why doesn't apache::php do this?
        ensure => "present",
      }
# add php.conf to apache so that php is handled properly
      file {"/etc/httpd/conf.d/php.conf":
        ensure => file,
        source => "puppet:///modules/laudanum/php.conf",
      }
    }
  }


#  apache::vhost { "local.${dev_domains[0]}": 
#    vhost_name	=> "local.${dev_domains[0]}",
#    docroot	=> "/srv/www/${dev_domains[0]}/public/",
#    serveradmin => "mr.snow@houseoflaudanum.com",
#    port	=> '80',
#    priority	=> '10',
#    logroot	=> "/srv/www/${dev_domains[0]}/logs/",
#    require	=> File["/srv/www/${dev_domains[0]}"],
#  }

  class { 'mysql': }
  class { 'mysql::server':
    config_hash => { 'root_password' => 'foo' }
  }
  database_user { 'vagrant@localhost':
    password_hash => mysql_password('vagrant')
  }
  
  case $operatingsystem {
      centos: { $php_mysql = "php-mysql" }
      redhat: { $php_mysql = "php-mysql" }
      debian: { $php_mysql = "php5-mysql" }
      ubuntu: { $php_mysql = "php5-mysql" }
      default: { fail("Unrecognized operating system for webserver") }
      # "fail" is a function. We'll get to those later.
  }
  package { $php_mysql:
    ensure => "present",
  }

# add githubs host key so we don't get warnings
  file {"/home/vagrant/.ssh/known_hosts":
    ensure => file,
    source => 'puppet:///modules/laudanum/known_hosts',
  }

# generate a host key for us to use at github
# either we've provided one at ../ssh-keys/github.rsa
# or we're going to create one
  file {"/home/vagrant/.ssh/github.rsa":
    ensure => file,
    source => '/ssh-config/id_rsa',
  }
  file {"/home/vagrant/.ssh/github.rsa.pub":
    ensure => file,
    source => '/ssh-config/id_rsa.pub',
  }
  exec { "github_ssh_keys":
    command => "/usr/bin/ssh-keygen -f /home/vagrant/.ssh/github.rsa",
    creates => "/home/vagrant/.ssh/github.rsa"
  }

  # centos policy tools
  # package { "policycoreutils-python":
  #  ensure => "present",
  # }
  # reset the policy on /srv/www
  # exec { "srv_www_policy":
  #   command => "semanage fcontext -a -t httpd_sys_content_t /srv/www &&  restorecon -v /srv/www",
  # }

  case $operatingsystem {
    centos: { 
# http://www.cyberciti.biz/faq/howto-disable-httpd-selinux-security-protection/#comments
# disable selinux for this boot
      exec { "selinux_off":
        command => "/usr/sbin/setenforce 0",
      }
      # and disable it permanently
      file { "/etc/selinux/config":
        ensure => "file",
        source => "puppet:///modules/laudanum/selinux_config",
        owner => "root",
        group => "root",
      }
    }
  }
}


class laudanum_drupal7_box {
  package { "bzr":
    ensure => "present",
  }
  package { "unzip":
    ensure => "present",
  }
  package { "subversion":
    ensure => "present",
  }
  package { "sendmail":
    ensure => "present",
  }

  case $operatingsystem {
      centos: { $php_pdo = "php-pdo" }
      redhat: { $php_pdo = "php-pdo" }
      debian: { $php_pdo = "php5-sqlite" }
      ubuntu: { $php_pdo = "php5-sqlite" }
      default: { fail("Unrecognized operating system for webserver") }
      # "fail" is a function. We'll get to those later.
  }
  package { $php_pdo:  # enables Sqlite (Quick Drupal requirement)
    ensure => "present",
  }

  case $operatingsystem {
      centos: { $php_gd = "php-gd" }
      redhat: { $php_gd = "php-gd" }
      debian: { $php_gd = "php5-gd" }
      ubuntu: { $php_gd = "php5-gd" }
      default: { fail("Unrecognized operating system for webserver") }
      # "fail" is a function. We'll get to those later.
  }
  package { $php_gd:
    ensure => "present",
  }

  case $operatingsystem {
    centos: { 
      package { "php-xml":  # enables DOM (Drupal Core requirement)
        ensure => "present",
      }
    }
  }

  class { "pear":
    package => "php-pear", # this installs php53 and php53-cli
  }

  # If no version number is supplied, the latest stable release will be
  # installed. In this case, upgrade PEAR to 1.9.2+ so it can use
  # pear.drush.org without complaint.
  pear::package { "PEAR": }
  pear::package { "Console_Table": }

  # $ sudo pear upgrade
  # $ sudo pear channel-discover pear.drush.org
  # $ sudo pear install drush/drush-6.0.0

  # Version numbers are supported.
  pear::package { "drush":
    version => "6.0.0",
    repository => "pear.drush.org",
  }

  # loop over domains creating drupal sites
  create_drupal_site { $dev_domains: }
}

exec { "networking_restart":
   command => "/etc/init.d/networking restart",
}


include laudanum_dev_box
include laudanum_drupal7_box
