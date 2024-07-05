(* TODO: Implement handler, handler should react to all future messages *)

(* open Lwt *)
(* let handle_incoming_string msg =
  Logs.info (fun m -> m "Receiveed from StdIn: '%s'" msg)

let rec handle_standart_input ic =
  Lwt_io.read_line_opt ic >>=
  (fun msg ->
      match msg with
      | Some msg -> handle_incoming_string msg; handle_standart_input ic
      | None -> Logs_lwt.info (fun m -> m "Input stream closed") >>= return) *)
  

  
  (* let input_stream = Lwt_io.read_lines Lwt_io.stdin in
  let _ = Lwt_stream.iter (fun line -> Logs.info (fun m -> m "Receiveed from StdIn: '%s'" line)) input_stream in *)
  
  
  (* TODO: StdIn to endless Stream *)
  (* let _ = handle_standart_input Lwt_io.stdin in
  let in_stream = Lwt_io.read_lines Lwt_io.stdin in
  let _ = Lwt_stream.peek (fun line -> Logs.info (fun m -> m "Message: %s" line)) in_stream in *)
