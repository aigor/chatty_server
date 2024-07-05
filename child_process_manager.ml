open Lwt

let rec handle_process_output ic process_id () =
  Lwt_io.read_line_opt ic >>=
  (fun output_msg -> match output_msg with
      | Some msg -> (
          Logs_lwt.info(fun m -> m "[process-%i] ### %s" process_id msg) >>= 
          handle_process_output ic process_id)
      | None -> Logs_lwt.info (fun m -> m "[process-%i] Process exited, restarting..." process_id) >>= return)

let spawn_child_processes app_name process_amount host_application_tcp_port = 
  let proces_id = 10 in
  Logs.info (fun m -> m "Starting %i child processes to connect to TCP server on port %i" process_amount host_application_tcp_port);
  (* TODO: Use actual required child amount *)
  (* TODO: Handle child process termination & respawn *)

  let child_process_command = app_name ^ " -child " ^ string_of_int host_application_tcp_port in
  Logs.info (fun m -> m "[process-%i] Starting child process with command: %s" proces_id child_process_command);
  let command = Lwt_process.shell child_process_command in
  let process = Lwt_process.open_process_full command in
  handle_process_output process#stdout proces_id ()