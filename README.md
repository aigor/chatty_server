# Simple chatty TCP server implemented with OCaml and LWT

Short description of the application:
 * Main application starts a TCP server which communicates with all connected clients
 * The content of the main application's stdin is distributed between all TCP server clients
 * Main application starts multiple child processes:
   * The desired process count configuration is set by application arguments
   * Each child process connects to the TCP server (from the main application)
   * Each child process receives and acknowledges TCP messages
   * Each child process sends `KEEP_ALIVE` messages to the TCP server
   * Each child process terminates its execution after some random but preconfigured time
   * Main process respawn terminated child process to sustain the desired child process count
  

## Environment

Requires Opam, Ocaml (4.14.0), Dune, and the following libraries: `lwt lwt.unix logs logs.fmt logs.lwt`.

## Running Example (MacOS, Linux)

To run the application, execute the following in the shell:

```
./generate-data.sh | ./run.sh
```

Here, `./generate-data.sh` produces some data that becomes the application's stdin.
In the `run.sh` file, it is possible to change the amount of desired child processes.
