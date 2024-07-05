(* Server mode: expose TCP port and handle new connections *)

open Lwt

let listen_address = Unix.inet_addr_loopback
let backlog = 10

(* TODO: Distinquish ACK message and other messages *)
let handle_incoming_message msg =
    match msg with
    | "KEEP_ALIVE" -> Some "KEEP_ALIVE_ACK"
    | _ -> None

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

let next_connection_id =
  let counter = ref 0 in
  fun () ->
    incr counter;
    !counter       
        
let accept_connection conn =
    let connection_id = next_connection_id () in
    let fd, _ = conn in
    let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
    Lwt.on_failure (handle_connection ic oc connection_id ()) (fun e -> Logs.err (fun m -> m "%s" (Printexc.to_string e) ));
    Logs_lwt.info (fun m -> m "[%i] New connection" connection_id) >>= return

let create_socket port =
    let open Lwt_unix in
    let sock = socket PF_INET SOCK_STREAM 0 in
    bind sock @@ ADDR_INET(listen_address, port) |> (fun x -> ignore x);
    listen sock backlog;
    sock

let create_server sock =
    let rec serve () =
        Lwt_unix.accept sock >>= accept_connection >>= serve
    in serve

let create_socket_server application_port =
  let sock = create_socket application_port in
  let _ = Logs_lwt.info (fun m -> m "TCP server is listening on port %i" application_port) in
  create_server sock