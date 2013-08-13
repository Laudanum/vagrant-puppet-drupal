# init.pp
class holly_drupal(
  $domains = 'example.com'
) {

  include apache
  include mysql

  # if $domains is not an array cast it as an array

  define site {
    file {"/srv/www/${name}":
      ensure => directory,
      mode   => 755,
    }

  # apache is defining this already--but permissions are wrong?
  #  file {"${name}_drupal_root":
  #    name => "/srv/www/${name}/local",
  #    ensure => directory,
  #    mode   => 755,
  #  }

    file {"/srv/www/${name}/backup":
      ensure => directory,
      mode   => 755,
    }

    file {"/srv/www/${name}/content":
      ensure => directory,
      mode   => 755,
    }

    $dbname = regsubst($name, '\.', '_', 'G')

  # cant' use vagrant (as mysql complains about duplicate users)
  #  mysql::db { "${name}_local":
  #    user     => "${name}",
  #    password => "${name}",
  #    host     => 'localhost',
  #    grant    => ['all'],
  #  }
    database { "${dbname}_local":
      ensure  => 'present',
      charset => 'utf8',
      require => [ Package["mysql_client"], ],
    }
    database_grant { "vagrant@localhost/${dbname}_local":
      privileges => ['all'] ,
    }
    
  # @TODO currently drupal::site overwrites settings. thats bad
  #  drupal::site { "${name}":
  #    databases => { 
  #      "default" => { 
  #        "default" => { 
  #          database  => "${dbname}_local", 
  #          username  => 'vagrant', 
  #          password => 'vagrant', 
  #          host => 'localhost', 
  #          port => '', 
  #          driver => 'mysql', 
  #          prefix => ''
  #        }
  #      }
  #    },
  #    drupal_root => "/srv/www/${name}/local",
  #    conf        => {},
  #    url         => "local.${name}",
  #    aliases     => [],
  #  }


    apache::vhost { "local.${name}":
      docroot       => "/srv/www/${name}/local",
      port          => 80,
  #    serveraliases => $aliases,
      serveradmin   =>  'admin@${name}',
      logroot       => "/var/log/$apache::params::apache_name/${name}",
      override      => "All",
    }
  }

  holly_drupal::site{$domains: }    
}