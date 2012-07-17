class centos6 {
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
  } 

}


include centos6
