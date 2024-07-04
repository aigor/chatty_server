let usage_msg = "chatty_server <number_of_child_processes>"

let default_child_prcesses = 16
let child_processes = ref default_child_prcesses
let arg_parser arg = 
  match int_of_string_opt arg with
  | Some value -> child_processes := value
  | None -> child_processes := default_child_prcesses

let () =
  if Array.length Sys.argv > 2 then 
    begin 
      print_endline "Aapplication accepts only one argument: <number_of_child_processes>";
      exit 1
    end;
  Arg.parse [] arg_parser usage_msg;

  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);

  Logs.info (fun m -> m "Chatting with sometimes faulty chield processes, strating %i processes" !child_processes);