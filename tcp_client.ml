(**
   Client mode: 
   Connects to the TCP server and communicates with it.
   When it receives a message from the TCP server, it replies with the ACK_RECEIVED <original-message-length> message.  
   It sends KEEP_ALIVE messages at random 5 to 20-second intervals.
   Finishes process execution at random intervals between 60 to 120 seconds.
*)

open Lwt

let tcp_server_host = "127.0.0.1"
let keep_alive_time_range_in_seconds = (5, 20)
let child_process_lifetime_in_seconds = (60, 120)

let random_float_from_interval (from_value, to_value) =
  float_of_int (from_value + Random.int (to_value - from_value))

let handle_incoming_message msg =
  match msg with
  | "KEEP_ALIVE_ACK" -> None
  | msg -> Some ("ACK_RECEIVED " ^ string_of_int (String.length msg))

let rec keep_alive_handler oc () = 
  let keep_alive = "KEEP_ALIVE" in  
  Lwt.bind (Lwt_unix.sleep (random_float_from_interval keep_alive_time_range_in_seconds)) 
    (fun () -> Lwt_io.write_line oc keep_alive >>= keep_alive_handler oc)

let rec handle_connection ic oc () =
  Lwt_io.read_line_opt ic >>=
  (fun incoming_msg -> match incoming_msg with
      | Some incoming_msg -> 
          (
              match handle_incoming_message incoming_msg with
              | Some msg -> Lwt_io.write_line oc msg >>= handle_connection ic oc
              | None -> handle_connection ic oc ())
      | None -> Logs_lwt.info (fun m -> m "Server unexpectedly closed connection") >>= 
         fun () -> Lwt.fail Exit >>= return)

let client_connect host port =
  let sockaddr = Unix.ADDR_INET (Unix.inet_addr_of_string host, port) in
  let sock = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  Lwt_unix.connect sock sockaddr >>= fun () ->
  let ic = Lwt_io.of_fd ~mode:Lwt_io.input sock in
  let oc = Lwt_io.of_fd ~mode:Lwt_io.output sock in
  Lwt.async (keep_alive_handler oc);
  handle_connection ic oc () >>= fun () ->
  Lwt_unix.close sock

let register_future_child_process_termination () =
  Lwt.bind (Lwt_unix.sleep (random_float_from_interval child_process_lifetime_in_seconds)) 
    (fun () -> Lwt.fail Exit)

let start_tcp_client application_port =
  Lwt.async (register_future_child_process_termination);
  client_connect tcp_server_host application_port