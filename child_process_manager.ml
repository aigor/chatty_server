(* TODO: Child process implementation here *)

let spawn_child_processes app_name process_amount host_application_tcp_port = 
  Logs.info (fun m -> m "Starting %i child processes to connect to TCP server on port %i" process_amount host_application_tcp_port);
  (* TODO: Use actual required child amount *)
  for proces_id = 1 to 1 do
    Logs.info (fun m -> m "[process-%i] Starting child process" proces_id);
    let child_process_command = app_name ^ " -child " ^ string_of_int host_application_tcp_port in
    Logs.info (fun m -> m "Child command: %s" child_process_command);
  done;
  Logs_lwt.info (fun m -> m "Started %i child processes to handle required work" process_amount)