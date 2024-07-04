let usage_message = "chatty_server <number_of_child_processes>"

let resolve_app_arguments_or_exit default_child_prcesses = 
  if Array.length Sys.argv > 2 then 
    begin 
      print_endline "Aapplication accepts only one argument: <number_of_child_processes>";
      exit 1
    end;

  let child_processes = ref default_child_prcesses in
  let arg_parser arg = 
    match int_of_string_opt arg with
    | Some value -> child_processes := value
    | None -> child_processes := default_child_prcesses in

  Arg.parse [] arg_parser usage_message;
  !child_processes
