class donodejs::monitor (

  # class arguments
  # ---------------
  # setup defaults

  $port = 3000,
  $content = 'Express',
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  if ($port) {
    @nagios::service { "http_content:${port}-donodejs-${::fqdn}":
      # no DNS, so need to refer to machine by external IP address
      check_command => "check_http_port_url_content!${::ipaddress}!${port}!/!'${content}'",
    }
    @nagios::service { "int:process_node-donodejs-${::fqdn}":
      check_command => "check_procs!1:!1:!node",
    }
  }

}
