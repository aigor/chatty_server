let default_child_prcesses = 16
let application_port = 54321


open Lwt
let run_server_mode child_processes =
  Logging.setup_logging_infrastructure ~log_filename:"application.log";
  Logs.info (fun m -> m "=== Chatty Server ===");
  Logs.info (fun m -> m "Chatting with sometimes faulty chield processes (%i processes)" child_processes);

  (* let _ = Lwt_main.run (Lwt_io.write_lines Lwt_io.stdout (Lwt_io.read_lines Lwt_io.stdin)) in *)

  let simple_additional_thread () = Logs_lwt.info (fun m -> m "Some additiona work") in

  let serve = Tcp_server.create_socket_server application_port in
  (* Lwt_main.run @@ serve (); *)
  Lwt_main.run ( serve () <&> simple_additional_thread ())


let run_child_mode parent_app_tcp_port =
  Logging.setup_lightwait_logging_infrastructure ();
  Logs.info (fun m -> m "Running in the child mode. Parent application TPC port: %i" parent_app_tcp_port)

let() = 
  let app_mode = App_args.resolve_app_mode_or_exit default_child_prcesses application_port in
  match app_mode with
  | ParentApp child_processes -> run_server_mode child_processes
  | ChildApp paretn_app_tcp_port -> run_child_mode paretn_app_tcp_port