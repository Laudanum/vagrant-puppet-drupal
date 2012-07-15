class centos6 {
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
}


include centos6