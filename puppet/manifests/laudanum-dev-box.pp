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

  class {'apache': }
  class {'apache::php': }

  apache::vhost { "local.${domain[0]}": 
    docroot	=> "/srv/www/${domain[0]}/public/",
    serveradmin => "mr.snow@houseoflaudanum.com",
    port	=> '80',
    ipaddr	=> '127.0.0.1',
    priority	=> '10',
    logroot	=> "/srv/www/${domain[0]}/logs/",
  } 

}


include laudanum_dev_box
