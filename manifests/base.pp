define donodejs::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $port = 3000,
  $app_name = 'hellonode',

  # install directory
  $target_dir = '/var/www/html',
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  # create and inflate node/express example
  exec { 'donodejs-base-create' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "express ${target_dir}/${app_name} && cd ${target_dir}/${app_name} && npm install",
    user => $user,
    cwd => "/home/${user}",
  }

  # create symlink from our home folder
  file { "/home/${user}/${app_name}" :
    ensure => 'link',
    target => "${target_dir}/${app_name}",
  }

}
