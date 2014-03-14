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

  # install node and npm
  class { 'nodejs' :
    manage_repo => true,
  }
  
  anchor { 'donodejs-node-ready' : }
  
  # install express
  package { 'express':
    ensure   => present,
    provider => 'npm',
    require  => Anchor['donodejs-node-ready'],
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