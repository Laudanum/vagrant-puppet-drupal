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

}


include laudanum_dev_box
