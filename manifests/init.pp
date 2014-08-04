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
  class { 'nodejs' :
    manage_repo => true,
    require => [Exec['up-to-date']],
    before => Anchor['donodejs-node-ready'],
  }

  # # use node default version to create 'node' and 'npm' symlinks, without version number
  # file { "donodejs-symlink-bin-without-version-node":
  #   ensure  => 'link',
  #   path    => "${donodejs::params::node_target_dir}/node",
  #   target  => "${donodejs::params::node_unpack_folder}/bin/node",
  #   require => [Class['nodejs']],
  #   before  => Anchor['donodejs-node-ready'],
  # }
  # file { "donodejs-symlink-bin-without-version-npm":
  #   ensure  => 'link',
  #   path    => "${donodejs::params::node_target_dir}/npm",
  #   target  => "${donodejs::params::node_unpack_folder}/bin/npm",
  #   require => [Class['nodejs']],
  #   before  => Anchor['donodejs-node-ready'],
  # }

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
    path => "/bin:/usr/bin:${donodejs::params::node_bin}:/sbin:/usr/sbin",
    command => 'npm update -g',
    before => Anchor['donodejs-npm-ready'],
  }

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

}