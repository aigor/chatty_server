(** 
  SOME USAFUL CODE EXAMPLES

let rec read_lines ic =
  Lwt_io.read_line_opt ic >>= function
  | Some line ->
    Lwt_io.printf "Received: %s\n%!" line >>= fun () ->
    read_lines ic
  | None -> Lwt.return_unit

(* Function to run a process and read its output continuously *)
let run_process_and_read command =
  let process = Lwt_process.open_process_in command in
  Lwt.async (fun () -> read_lines process#stdout);
  process#status >>= fun status ->
  Lwt_io.printf "Process terminated with status: %s\n%!"
    (match status with
      | Unix.WEXITED n -> Printf.sprintf "exited with code %d" n
      | Unix.WSIGNALED n -> Printf.sprintf "killed by signal %d" n
      | Unix.WSTOPPED n -> Printf.sprintf "stopped by signal %d" n)

let () = 
   let command = ("ls", [| "ls"; "-la" |]) in
   let _ = Lwt_main.run (run_process_and_read command) in
   ();

*)