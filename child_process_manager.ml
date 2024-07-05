(* TODO: Child process implementation here *)  
open Lwt


(*

   let rec handle_connection ic oc connection_id () =
    Lwt_io.read_line_opt ic >>=
    (fun incoming_msg -> match incoming_msg with
        | Some incoming_msg -> 
            (
                Logs.info(fun m -> m "[%i] << %s" connection_id incoming_msg);
                match handle_incoming_message incoming_msg with
                | Some msg -> (
                    Logs.info(fun m -> m "[%i] >> %s" connection_id msg);
                    Lwt_io.write_line oc msg >>= handle_connection ic oc connection_id
                )
                | None -> handle_connection ic oc connection_id ())
        | None -> Logs_lwt.info (fun m -> m "[%i] Connection closed" connection_id) >>= return)

    Lwt.on_failure (handle_connection ic oc connection_id ()) (fun e -> Logs.err (fun m -> m "%s" (Printexc.to_string e) ));
    Logs_lwt.info (fun m -> m "[%i] New connection" connection_id) >>= return


*)

let rec handle_process_output ic process_id () =
  Lwt_io.read_line_opt ic >>=
  (fun output_msg -> match output_msg with
      | Some msg -> (
          Logs.info(fun m -> m "[process-%i] ### %s" process_id msg); 
          handle_process_output ic process_id ())
      | None -> Logs_lwt.info (fun m -> m "[process-%i] Process exited, restarting..." process_id) >>= return)

let spawn_child_processes app_name process_amount host_application_tcp_port = 
  let proces_id = 10 in
  Logs.info (fun m -> m "Starting %i child processes to connect to TCP server on port %i" process_amount host_application_tcp_port);
  (* TODO: Use actual required child amount *)
  (* TODO: Handle application termination *)

  let child_process_command = app_name ^ " -child " ^ string_of_int host_application_tcp_port in
  Logs.info (fun m -> m "[process-%i] Starting child process with command: %s" proces_id child_process_command);
  let command = Lwt_process.shell child_process_command in
  let process = Lwt_process.open_process_full command in
  handle_process_output process#stdout proces_id ()