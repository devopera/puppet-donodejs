define donodejs::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $app_port = 3000,
  $app_name = 'hellonode',

  # install directory
  $target_dir = '/var/www/html',

  $firewall = true,
  $monitor = true,
  
  # create symlink and if so, where
  $symlinkdir = false,

  # end of class arguments
  # ----------------------
  # begin class

) {

  if ($firewall) {
    # open port
    class { 'donodejs::firewall' :
      port => $app_port,
    }
  }

  if ($monitor) {
    # setup monitoring
    class { 'donodejs::monitor' :
      port => $app_port,
    }
  }

  # create and inflate node/express example
  exec { "donodejs-base-create-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "express ${target_dir}/${app_name} && cd ${target_dir}/${app_name} && npm install",
    user => $user,
    cwd => "/home/${user}",
  }

  # create symlink from our home folder
  if ($symlinkdir) {
    # create symlink from directory to repo (e.g. user's home folder)
    file { "${symlinkdir}/${app_name}" :
      ensure => 'link',
      target => "${target_dir}/${app_name}",
      require => [Exec["donodejs-base-create-${title}"]],
    }
  }

}
