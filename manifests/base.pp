define donodejs::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',
  $port = 3000,
  $app_name = $title,
  $app_script = 'bin/www',
  $content = 'Express',

  # install directory
  $target_dir = '/var/www/node',

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
      check_command => "check_nrpe_procs_postfix",
    }
  }

  # if we've got a message of the day, include
  @domotd::register { "Node(${port})" : }

  # check that target dir exists
  if ! defined(File["${target_dir}"]) {
    docommon::stickydir { "${target_dir}":
      user => $user,
      group => $group,
      context => 'httpd_sys_content_t',
      before => [Exec["donodejs-base-create-${title}"]],
    }
  }

  # create and inflate node/express example
  exec { "donodejs-base-create-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "express ${target_dir}/${app_name} && cd ${target_dir}/${app_name} && npm install",
    user => $user,
    group => $group,
    cwd => "/home/${user}",
  }

  # create service and start on machine startup
  case $operatingsystem {
    centos, redhat, fedora: {
    }
    ubuntu, debian: {
    }
  }
  # experimenting with symmetric file resource for both CentOS and Ubuntu
  file { "donodejs-base-service-script-${title}":
    name => "/etc/init.d/${app_name}",
    content => template('donodejs/service.erb'),
    owner => 'root',
    group => 'root',
    mode => '0755',
  }
  service { "donodejs-base-service-${title}":
    name => "${app_name}",
    enable => true,
    ensure => 'running',
    require => [Exec["donodejs-base-create-${title}"], File["donodejs-base-service-script-${title}"]],
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
