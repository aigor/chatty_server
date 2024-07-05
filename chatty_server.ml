let default_child_prcesses = 16
let application_port = 54321


open Lwt
let run_in_server_mode app_name child_processes =
  Logging.setup_logging_infrastructure ~log_filename:"application.log";
  Logs.info (fun m -> m "=== Chatty Server ===");
  Logs.info (fun m -> m "Chatting with sometimes faulty chield processes (%i processes)" child_processes);

  let input_messages_stream = Lwt_io.read_lines Lwt_io.stdin in
  Lwt.async(fun () -> Lwt_stream.iter (fun line -> Logs.info(fun m -> m "[stdin] Received: %s" line)) input_messages_stream);

  let serve_tcp = Tcp_server.create_socket_server application_port input_messages_stream in
  Lwt_main.run ( serve_tcp () <&> Child_process_manager.spawn_child_processes app_name child_processes application_port)

let run_in_child_mode parent_app_tcp_port =
  Logging.setup_lightwait_logging_infrastructure ();
  Logs.info (fun m -> m "Running in the child mode. Parent application TPC port: %i" parent_app_tcp_port);
  Lwt_main.run ( Tcp_client.start_tcp_client parent_app_tcp_port )

let () = 
  Random.self_init();
  let app_mode = App_args.resolve_app_mode_or_exit default_child_prcesses application_port in
  match app_mode with
  | ParentApp (aap_name, child_processes) -> run_in_server_mode aap_name child_processes
  | ChildApp paretn_app_tcp_port -> run_in_child_mode paretn_app_tcp_port