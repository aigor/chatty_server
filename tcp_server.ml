(* Server implementation: expose TCP port, handle connections, process messages. *)

open Lwt

let listen_address = Unix.inet_addr_loopback
let backlog = 10


let handle_incoming_message msg =
    match msg with
    | "KEEP_ALIVE" -> Some "KEEP_ALIVE_ACK"
    | _ -> None

let rec handle_connection ic oc connection_id () =
    Lwt_io.read_line_opt ic >>=
    (fun incoming_msg -> match incoming_msg with
        | Some incoming_msg -> 
            (
                Logs.info (fun m -> m "[connection: %i] << %s" connection_id incoming_msg);
                match handle_incoming_message incoming_msg with
                | Some msg -> (
                    Logs.info (fun m -> m "[connection: %i] >> %s" connection_id msg);
                    Lwt_io.write_line oc msg >>= handle_connection ic oc connection_id
                )
                | None -> handle_connection ic oc connection_id ())
        | None -> Logs_lwt.info (fun m -> m "[connection: %i] Connection closed" connection_id) >>= return)

let transfer_messages stream output_channel connection_id =
  let rec transfer () =
    Lwt_stream.get stream >>= function
    | Some message -> 
        Lwt_io.write_line output_channel message >>= fun () -> 
        Logs_lwt.info (fun m -> m "[connection: %i] >> %s" connection_id message) >>= fun () -> 
        transfer ()
    | None -> Logs_lwt.info (fun m -> m "Stream ended unexpectedly.")
  in
  Lwt.catch
  (fun () -> transfer ())
  (fun ex -> Logs_lwt.info (fun m -> m "[connection: %i] Cannot transfer message to connection: %s" connection_id (Printexc.to_string ex) ))


let next_connection_id =
  let counter = ref 0 in
  fun () ->
    incr counter;
    !counter       
        
let accept_connection message_stream conn =
    let connection_id = next_connection_id () in
    let fd, _ = conn in
    let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
    Lwt.on_failure (handle_connection ic oc connection_id ()) (fun e -> Logs.err (fun m -> m "%s" (Printexc.to_string e) ));

    Lwt.async(fun () -> transfer_messages message_stream oc connection_id);

    Logs_lwt.info (fun m -> m "[connection: %i] New connection established" connection_id) >>= return

let create_socket port =
    let open Lwt_unix in
    let sock = socket PF_INET SOCK_STREAM 0 in
    bind sock @@ ADDR_INET(listen_address, port) |> (fun x -> ignore x);
    listen sock backlog;
    sock

let create_server sock message_stream =
    let rec serve () =
        Lwt_unix.accept sock >>= accept_connection message_stream >>= serve
    in serve

let create_socket_server application_port message_stream =
  let sock = create_socket application_port in
  let _ = Logs_lwt.info (fun m -> m "TCP server is listening on port %i" application_port) in
  create_server sock message_stream