type application_name = string
type child_processes_amout = int
type parent_app_tcp_port = int

type application_mode = ParentApp of application_name * child_processes_amout | ChildApp of parent_app_tcp_port

let usage_message = "chatty_server [-child] <number_of_child_processes|host_tpc+port_for_child>"

let resolve_app_mode_or_exit default_child_prcesses default_parent_app_tcp_port = 
  if Array.length Sys.argv > 3 then 
    begin 
      print_endline "Aapplication accepts only the following arguments: [-child] <number_of_child_processes|host_tpc+port_for_child>";
      exit 1
    end;

  let application_name = Sys.argv.(0) in
  let child_mode = ref false in
  let speclist = [("-child", Arg.Set child_mode, "Running application in the child mode")] in 

  let app_argument = ref None in
  let arg_parser arg = 
    match int_of_string_opt arg with
    | Some value -> app_argument := Some value
    | _ -> app_argument := None in

  Arg.parse speclist arg_parser usage_message;

  match !child_mode with 
  | false -> ParentApp (application_name, match !app_argument with | Some value -> value | None -> default_child_prcesses)
  | true -> ChildApp (match !app_argument with | Some value -> value | None -> default_parent_app_tcp_port)

