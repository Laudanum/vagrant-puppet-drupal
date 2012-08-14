$dev_domains = [ "laudanum.net", "artlib.com.au", ] 

define create_drupal_site {
  drupal::site { "${name}":
    databases   => "${name}_local",
    drupal_root => "/srv/www/${name}",
    conf        => {},
    url         => "local.${name}",
    aliases     => [],
  }

}

class laudanum_dev_box {

  user { "apache": 
    ensure => "present", 
  }
  user { "puppet": 
    ensure => "present", 
  }
  package { "git":
    ensure => "present",
  }
  package { "wget":
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
      mode => 644,
  }
  file {"/srv/www/${dev_domains[0]}":
      ensure => directory,
      mode   => 644,
  }

  class {'apache': }
  class {'apache::php': }

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

  mysql::db { "${dev_domains[0]}_local":
    user     => 'myuser',
    password => 'mypass',
    host     => 'localhost',
    grant    => ['all'],
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
    source => '/ssh-config/github.rsa',
  }
  file {"/home/vagrant/.ssh/github.rsa.pub":
    ensure => file,
    source => '/ssh-config/github.rsa.pub',
  }
  exec { "github_ssh_keys":
    command => "/usr/bin/ssh-keygen -f /home/vagrant/.ssh/github.rsa",
    creates => "/home/vagrant/.ssh/github.rsa"
  }
  file {"/home/vagrant/.ssh/config":
    ensure => file,
    source => '/ssh-config/config',
    mode => 600,
  }

  # centos policy tools
  # package { "policycoreutils-python":
  #  ensure => "present",
  # }
  # reset the policy on /srv/www
  # exec { "srv_www_policy":
  #   command => "semanage fcontext -a -t httpd_sys_content_t /srv/www &&  restorecon -v /srv/www",
  # }
  
  # http://www.cyberciti.biz/faq/howto-disable-httpd-selinux-security-protection/#comments
  # disable selinux for this boot
  exec { "selinux_off":
    command => "/usr/sbin/setenforce 0",
  }
  # and disable it permanently
  file { "/etc/selinux/config":
    ensure => "file",
    source => "puppet:///modules/laudanum/selinux_config",
  }
}


class laudanum_drupal7_box {
  package { "bzr":
    ensure => "present",
  }
  package { "subversion":
    ensure => "present",
  }
  package { "sendmail":
    ensure => "present",
  }
  package { "php-pdo":  # enables Sqlite (Quick Drupal requirement)
    ensure => "present",
  }
  package { "php-gd":
    ensure => "present",
  }
  package { "php-xml":  # enables DOM (Drupal Core requirement)
    ensure => "present",
  }

  class { "pear":
    package => "php-pear", # this installs php53 and php53-cli
  }

  # If no version number is supplied, the latest stable release will be
  # installed. In this case, upgrade PEAR to 1.9.2+ so it can use
  # pear.drush.org without complaint.
  pear::package { "PEAR": }
  pear::package { "Console_Table": }

  # Version numbers are supported.
  pear::package { "drush":
    version => "6.0.0",
    repository => "pear.drush.org",
  }

  # loop over domains creating drupal sites
  create_drupal_site { $dev_domains: }
}



include laudanum_dev_box
include laudanum_drupal7_box
