open Lwt

let rec handle_process_output process_id oc () =
  Lwt_io.read_line_opt oc >>=
  (fun output_msg -> match output_msg with
      | Some msg -> (
          Logs_lwt.info(fun m -> m "[process: %i] ### %s" process_id msg) >>= 
          handle_process_output process_id oc)
      | None -> Logs_lwt.info (fun m -> m "[process: %i] Process output stream is closed, process terminated" process_id) >>= return)

let start_process app_name host_application_tcp_port process_id =
  let child_process_command = app_name ^ " -child " ^ string_of_int host_application_tcp_port in
  Logs.info (fun m -> m "[process: %i] Starting child process with command: %s" process_id child_process_command);
  let command = Lwt_process.shell child_process_command in
  Lwt_process.open_process_full command

let rec spawn_child_process app_name host_application_tcp_port process_id () : unit Lwt.t =
  let process = start_process app_name host_application_tcp_port process_id in
  handle_process_output process_id process#stdout () >>= fun () ->
  Lwt.async (spawn_child_process app_name host_application_tcp_port process_id);
  Logs_lwt.info (fun m -> m "[process: %i] Child process restarted" process_id) >>= return


let spawn_child_processes app_name process_amount host_application_tcp_port : unit Lwt.t =
  List.init process_amount (fun i -> i + 1) |>
  List.map (fun process_id -> spawn_child_process app_name host_application_tcp_port process_id ()) |>
  Lwt.join
