class donodejs (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $port = 3000,

  $firewall = true,
  $monitor = true,
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  # install node and npm (after dist-upgrade on Ubuntu)
  class { 'nodejs' :
    manage_repo => true,
    require => [Exec['up-to-date']],
    before => Anchor['donodejs-node-ready'],
  }
  
  case $operatingsystem {
    centos, redhat, fedora: {
    }
    ubuntu, debian: {
      # Ubuntu requires a kick to get up to the right version
      exec { 'donodejs-force-node-update' :
        command => '/usr/bin/apt-get -y dist-upgrade',
        require => [Class['nodejs']],
        before => Anchor['donodejs-node-ready'],
      }
    }
  }
  
  anchor { 'donodejs-node-ready' : }->
  
  # update using npm
  exec { 'donodejs-node-npm-update' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'npm update -g',
  }
  
  anchor { 'donodejs-npm-ready' : }

  # install express
  package { 'express':
    ensure   => present,
    provider => 'npm',
    require => [Anchor['donodejs-npm-ready']],
  }

  if ($firewall) {
    # open port (3000)
    class { 'donodejs::firewall' :
      port => $port,
    }
  }

  if ($monitor) {
    # setup monitoring
    class { 'donodejs::monitor' :
      port => $port,
    }
  }

}