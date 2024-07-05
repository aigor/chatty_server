(* Client mode: connect to TCP server and communicate with it *)

open Lwt

(* TODO: Add message handler *)
(* TODO: Add KEEP_ALIVE with random interval 5 to 20 seconds *)
(* TODO: Finish process in random interval from 60 to 120 seconds *)

let handle_incoming_message msg =
  match msg with
  | "KEEP_ALIVE_ACK" -> None
  | msg -> Some ("ACK_RECEIVED " ^ string_of_int (String.length msg))

let rec handle_connection ic oc () =
  Lwt_io.read_line_opt ic >>=
  (fun incoming_msg -> match incoming_msg with
      | Some incoming_msg -> 
          (
              Logs.info(fun m -> m "[child] << %s" incoming_msg);
              match handle_incoming_message incoming_msg with
              | Some msg -> (
                  Logs.info(fun m -> m "[child] >> %s" msg);
                  Lwt_io.write_line oc msg >>= handle_connection ic oc
              )
              | None -> handle_connection ic oc ())
      | None -> Logs_lwt.info (fun m -> m "Connection closed") >>= return)

let client_connect host port =
  Lwt_io.printf "Connecting to %s:%d...\n" host port >>= fun () ->
    let sockaddr = Unix.ADDR_INET (Unix.inet_addr_of_string host, port) in
    let sock = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    Lwt_unix.connect sock sockaddr >>= fun () ->
    let ic = Lwt_io.of_fd ~mode:Lwt_io.input sock in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.output sock in
    handle_connection ic oc () >>= fun () ->
    Lwt_unix.close sock

let start_tcp_client application_port =
  let host = "127.0.0.1" in
  client_connect host application_port