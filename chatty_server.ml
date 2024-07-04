let default_child_prcesses = 16
let child_processes = App_args.resolve_app_arguments_or_exit default_child_prcesses

let () =
  Logging.setup_logging_infrastructure ~log_filename:"application.log";
  
  Logs.info (fun m -> m "Chatting with sometimes faulty chield processes (%i processes)" child_processes);

