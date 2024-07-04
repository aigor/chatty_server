let default_child_prcesses = 16
let application_port = 54321

let child_processes = App_args.resolve_app_arguments_or_exit default_child_prcesses

let () =
  Logging.setup_logging_infrastructure ~log_filename:"application.log";
  Logs.info (fun m -> m "=== Chatty Server ===");
  Logs.info (fun m -> m "Chatting with sometimes faulty chield processes (%i processes)" child_processes);

  let serve = Tcp_server.create_socket_server application_port in
  Lwt_main.run @@ serve ()