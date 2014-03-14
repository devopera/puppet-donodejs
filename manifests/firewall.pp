class donodejs::firewall (

  # class arguments
  # ---------------
  # setup defaults

  $port = 3000,
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  @docommon::fireport { "donodejs-node-server-${port}":
    port => $port,
    protocol => 'tcp',
  }

}
