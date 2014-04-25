define donodejs::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $port = 3000,
  $app_name = $title,
  $content = 'Express',

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
    @docommon::fireport { "donodejs-node-server-${port}":
      port => $port,
      protocol => 'tcp',
    }
  }

  if ($monitor) {
    # setup monitoring
    @nagios::service { "http_content:${port}-donodejs-${::fqdn}":
      # no DNS, so need to refer to machine by external IP address
      check_command => "check_http_port_url_content!${::ipaddress}!${port}!/!'${content}'",
    }
    @nagios::service { "int:process_node-donodejs-${::fqdn}":
      check_command => "check_procs!1:!1:!node",
    }
  }

  # if we've got a message of the day, include
  @domotd::register { "Node(${port})" : }

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
