class laudanum_dev_box {
  $domain = [ "laudanum.net", ] 

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

  host { "host-local.${domain[0]}":
    ensure => "present",
    ip     => "127.0.0.1",
    host_aliases => [ "local.${domain[0]}", "localhost", "vagrant-centos-6.localdomain"],
  }

# Create necessary parent directories.
  file {["/srv", "/srv/www"]:
      ensure => directory,
      mode => 644,
  }
  file {"/srv/www/${domain[0]}":
      ensure => directory,
      mode   => 644,
  }

  class {'apache': }
  class {'apache::php': }

  apache::vhost { "local.${domain[0]}": 
    vhost_name	=> "local.${domain[0]}",
    docroot	=> "/srv/www/${domain[0]}/public/",
    serveradmin => "mr.snow@houseoflaudanum.com",
    port	=> '80',
    priority	=> '10',
    logroot	=> "/srv/www/${domain[0]}/logs/",
    require	=> File["/srv/www/${domain[0]}"],
  }
  class { 'mysql': }
  class { 'mysql::server':
    config_hash => { 'root_password' => 'foo' }
  }

  mysql::db { "${domain[0]}_local":
    user     => 'myuser',
    password => 'mypass',
    host     => 'localhost',
    grant    => ['all'],
  }
}


include laudanum_dev_box
