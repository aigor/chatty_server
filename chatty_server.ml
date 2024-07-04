open Lwt.Infix

let usage_msg = "chatty_server <number_of_child_processes>"

let default_child_prcesses = 16
let child_processes = ref default_child_prcesses
let arg_parser arg = 
  match int_of_string_opt arg with
  | Some value -> child_processes := value
  | None -> child_processes := default_child_prcesses


  let lwt_file_reporter filename =
    let buf_fmt ~like =
      let b = Buffer.create 512 in
      Fmt.with_buffer ~like b,
      fun () -> let m = Buffer.contents b in Buffer.reset b; m
    in
    let app, app_flush = buf_fmt ~like:Fmt.stdout in
    let dst, dst_flush = buf_fmt ~like:Fmt.stderr in
    let reporter = Logs_fmt.reporter ~app ~dst () in
    let report src level ~over k msgf =
      let k () =
        let write () =
          Lwt_io.open_file ~flags:[Unix.O_WRONLY; Unix.O_CREAT; Unix.O_APPEND] ~perm:0o777 ~mode:Lwt_io.Output filename
          >>= fun fd -> (
            match level with
            | Logs.App -> Lwt_io.write fd (app_flush ())
            | _ -> Lwt_io.write fd (dst_flush ())
          )
            >>= fun () ->
              Lwt_io.close fd
        in
        let unblock () = over (); Lwt.return_unit in
        Lwt.finalize write unblock |> Lwt.ignore_result;
        k ()
      in
      reporter.Logs.report src level ~over:(fun () -> ()) k msgf;
    in
    { Logs.report = report }

let combine_reporters r1 r2 =
  let report = fun src level ~over k msgf ->
    let v = r1.Logs.report src level ~over:(fun () -> ()) k msgf in
    r2.Logs.report src level ~over (fun () -> v) msgf
  in
  { Logs.report }

let () =
  if Array.length Sys.argv > 2 then 
    begin 
      print_endline "Aapplication accepts only one argument: <number_of_child_processes>";
      exit 1
    end;
  Arg.parse [] arg_parser usage_msg;

  let lock = Mutex.create () in
  let lock () = Mutex.lock lock and unlock () = Mutex.unlock lock in
  Logs.set_reporter_mutex ~lock ~unlock;
  Logs.set_reporter (combine_reporters (lwt_file_reporter "application.log") (Logs_fmt.reporter ()));
  Logs.set_level (Some Debug);

  for _ = 1 to 1000 do
    Logs.info (fun m -> m "Chatting with sometimes faulty chield processes (%i processes)" !child_processes);
  done

