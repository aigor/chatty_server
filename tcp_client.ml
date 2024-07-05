(* Client mode: connect to TCP server and communicate with it *)

open Lwt

let client_connect host port =
  Lwt_io.printf "Connecting to %s:%d...\n" host port >>= fun () ->
    let sockaddr = Unix.ADDR_INET (Unix.inet_addr_of_string host, port) in
    let sock = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    Lwt_unix.connect sock sockaddr >>= fun () ->
    let ic = Lwt_io.of_fd ~mode:Lwt_io.input sock in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.output sock in
    Lwt_io.write_line oc "KEEP_ALIVE" >>= fun () ->
    Lwt_io.read_line ic >>= fun response ->
    Lwt_io.printf "Received from server: %s\n" response >>= fun () ->
    Lwt_unix.close sock

let start_tcp_client application_port =
  let host = "127.0.0.1" in
  client_connect host application_port