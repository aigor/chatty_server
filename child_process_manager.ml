open Lwt

let start_process app_name host_application_tcp_port process_id =
  let child_process_command = app_name ^ " -child " ^ string_of_int host_application_tcp_port in
  Logs.debug (fun m -> m "[process: %i] Starting child process with command: %s" process_id child_process_command);
  let command = Lwt_process.shell child_process_command in
  Lwt_process.open_process_full command

let process_status = function
| Unix.WEXITED n -> "exited with code " ^ string_of_int n
| Unix.WSIGNALED n -> "killed by signal " ^ string_of_int n
| Unix.WSTOPPED n -> "stopped by signal " ^ string_of_int n

let rec spawn_child_process app_name host_application_tcp_port process_id () : unit Lwt.t =
  let process = start_process app_name host_application_tcp_port process_id in
  process#status >>= fun status ->
  Lwt.async (spawn_child_process app_name host_application_tcp_port process_id);
  Logs_lwt.info (fun m -> m "[process: %i] Process terminated (%s) and was restarted" process_id (process_status status)) >>= return

let spawn_child_processes app_name process_amount host_application_tcp_port : unit Lwt.t =
  List.init process_amount (fun i -> i + 1) |>
  List.map (fun process_id -> spawn_child_process app_name host_application_tcp_port process_id ()) |>
  Lwt.join
