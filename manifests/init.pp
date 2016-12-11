class donodejs (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',

  # end of class arguments
  # ----------------------
  # begin class

) inherits donodejs::params {

  # install node and npm (after dist-upgrade on Ubuntu)
  #class { 'nodejs' :
  #  manage_repo => true,
  #  require => [Exec['up-to-date']],
  #  before => Anchor['donodejs-node-ready'],
  #}

  # https://github.com/joyent/node/wiki/installing-node.js-via-package-manager#enterprise-linux-and-fedora
  case $operatingsystem {
    centos, redhat, fedora: {
      $repo_source = 'https://rpm.nodesource.com/setup'
    }
    ubuntu, debian: {
      $repo_source = 'https://deb.nodesource.com/setup'
      # setup a symlink for nodejs on Ubuntu (not forced)
      exec { 'donodejs-symlink' :
        path => '/bin:/sbin:/usr/bin:/usr/sbin',
        command => 'ln -s /usr/bin/node /usr/bin/nodejs',
        require => [Package['nodejs']],
      }
    }
  }
  
  exec { 'donodejs-repo' :
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "curl -sL ${repo_source} | bash -",
  }
  if ! defined(Package['nodejs']) {
    package { 'nodejs' :
      require => Exec['donodejs-repo'],
      before => Anchor['donodejs-node-ready'],
    }
  }

  anchor { 'donodejs-node-ready' : }

  if ! defined(Package['npm']) {
    package { 'npm' :
      require => Anchor['donodejs-node-ready'],
      before => Anchor['donodejs-npm-ready'],
    }
  }
  
  # update using npm
  # temporarily disable npm update because 3.10.9 breaks RHEL7
  #exec { 'donodejs-node-npm-update' :
  #  path => "/bin:/usr/bin:${donodejs::params::node_bin}:/sbin:/usr/sbin",
  #  command => 'npm update -g',
  #  before => Anchor['donodejs-npm-ready'],
  #}

  anchor { 'donodejs-npm-ready' : }

  # install express and express command line
  if ! defined(Package['express']) {
    package { 'express':
      ensure   => present,
      provider => 'npm',
      require => [Anchor['donodejs-npm-ready']],
    }
  }
  if ! defined(Package['express-generator']) {
    package { 'express-generator':
      ensure   => present,
      provider => 'npm',
      require => [Anchor['donodejs-npm-ready']],
    }
  }

  # install forever for background operation
  if ! defined(Package['forever']) {
    package { 'forever':
      ensure   => present,
      provider => 'npm',
      require => [Anchor['donodejs-npm-ready']],
    }
  }
  # install localtunnel for convenience
  if ! defined(Package['localtunnel']) {
    package { 'localtunnel':
      ensure   => present,
      provider => 'npm',
      require => [Anchor['donodejs-npm-ready']],
    }
  }

}
