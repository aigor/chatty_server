let combine_reporters r1 r2 =
  let report = fun src level ~over k msgf ->
    let v = r1.Logs.report src level ~over:(fun () -> ()) k msgf in
    r2.Logs.report src level ~over (fun () -> v) msgf
  in
  { Logs.report }

(* TODO: It seems that the current implementation somtimes breaks file content while writing log data. *)
(* TODO: Incomplete implementation. We need file rotation, file retantion policy, and other basic logging features. *)
(* Potential alternative: Logs_lwt *)
open Lwt.Infix
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


let lwt_console_reporter () =
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
      let write () = match level with
      | Logs.App -> Lwt_io.write Lwt_io.stdout (app_flush ())
      | _ -> Lwt_io.write Lwt_io.stderr (dst_flush ())
      in
      let unblock () = over (); Lwt.return_unit in
      Lwt.finalize write unblock |> Lwt.ignore_result;
      k ()
    in
    reporter.Logs.report src level ~over:(fun () -> ()) k msgf;
  in
  { Logs.report = report }

let setup_lightwait_logging_infrastructure () = 
  let lock = Mutex.create () in
  let lock () = Mutex.lock lock and unlock () = Mutex.unlock lock in
  Logs.set_reporter_mutex ~lock ~unlock;
  Logs.set_reporter (lwt_console_reporter ());
  Logs.set_level (Some Debug)

let setup_logging_infrastructure ~log_filename = 
  (* TODO: What to do with mutex? *)
  (* let lock = Mutex.create () in
  let lock () = Mutex.lock lock and unlock () = Mutex.unlock lock in
  Logs.set_reporter_mutex ~lock ~unlock; *)
  Logs.set_reporter (combine_reporters (lwt_file_reporter log_filename) (lwt_console_reporter ()));
  Logs.set_level (Some Debug)