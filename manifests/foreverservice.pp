define donodejs::foreverservice (

  # class arguments
  # ---------------
  # setup defaults

  $app_name = $title,
  $app_script = 'bin/www',

  # install directory
  $target_dir = '/var/www/node',

  # end of class arguments
  # ----------------------
  # begin class

) {

  case $operatingsystem {
    centos, redhat, fedora: {
    }
    ubuntu, debian: {
    }
  }

  # experimenting with symmetric file resource for both CentOS and Ubuntu
  file { "donodejs-foreverservice-script-${title}":
    name => "/etc/init.d/${app_name}",
    content => template('donodejs/service.generic.erb'),
    owner => 'root',
    group => 'root',
    mode => '0755',
  }
  service { "donodejs-foreverservice-${title}":
    name => "${app_name}",
    enable => true,
    ensure => 'running',
    require => [File["donodejs-foreverservice-script-${title}"]],
  }

}
