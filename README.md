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


<details>
<summary>Example of the application log content (truncated)</summary>

```log
[INFO] === Chatty Server ===
[INFO] Chatting with sometimes faulty chield processes (2 processes)
[INFO] The TCP server is listening on port 54321
[INFO] [connection: 1] New connection established
[INFO] [connection: 2] New connection established
[INFO] [connection: 2] >> 2024-07-06 02:19:04 WPEEo9bG5nnnS/tkKyiJMDf3LJJ3fiPE
[INFO] [connection: 1] >> 2024-07-06 02:19:04 WPEEo9bG5nnnS/tkKyiJMDf3LJJ3fiPE
[INFO] [stdin] Received: 2024-07-06 02:19:04 WPEEo9bG5nnnS/tkKyiJMDf3LJJ3fiPE
[INFO] [connection: 2] << ACK_RECEIVED 52
[INFO] [connection: 1] << ACK_RECEIVED 52
[INFO] [stdin] Received: 2024-07-06 02:19:09 SwwzDVfYkl6EQicG6s5KvN+a
[INFO] [connection: 1] >> 2024-07-06 02:19:09 SwwzDVfYkl6EQicG6s5KvN+a
[INFO] [connection: 2] >> 2024-07-06 02:19:09 SwwzDVfYkl6EQicG6s5KvN+a
[INFO] [connection: 1] << ACK_RECEIVED 44
[INFO] [connection: 2] << ACK_RECEIVED 44
[INFO] [connection: 1] << KEEP_ALIVE
[INFO] [connection: 1] >> KEEP_ALIVE_ACK
[INFO] [connection: 2] >> 2024-07-06 02:19:14 uc767lNjpYB6BglzWDRWeCocwlelrmSpthkF
[INFO] [connection: 1] >> 2024-07-06 02:19:14 uc767lNjpYB6BglzWDRWeCocwlelrmSpthkF
[INFO] [stdin] Received: 2024-07-06 02:19:14 uc767lNjpYB6BglzWDRWeCocwlelrmSpthkF
[INFO] [connection: 2] << ACK_RECEIVED 56
[INFO] [connection: 1] << ACK_RECEIVED 56
[INFO] [connection: 2] << KEEP_ALIVE
[INFO] [connection: 2] >> KEEP_ALIVE_ACK
[INFO] [stdin] Received: 2024-07-06 02:19:19 MfWAP1EkbqLE/4cvWSvn0wJ1mEg=
[INFO] [connection: 1] >> 2024-07-06 02:19:19 MfWAP1EkbqLE/4cvWSvn0wJ1mEg=
[INFO] [connection: 2] >> 2024-07-06 02:19:19 MfWAP1EkbqLE/4cvWSvn0wJ1mEg=
[INFO] [connection: 1] << ACK_RECEIVED 48
[INFO] [connection: 2] << ACK_RECEIVED 48
[INFO] [connection: 2] >> 2024-07-06 02:19:24 kSwi5FZfWRCcn8O8a5AnSyXCF6/wYvUZWOp1NcWC
[INFO] [connection: 1] >> 2024-07-06 02:19:24 kSwi5FZfWRCcn8O8a5AnSyXCF6/wYvUZWOp1NcWC
[INFO] [stdin] Received: 2024-07-06 02:19:24 kSwi5FZfWRCcn8O8a5AnSyXCF6/wYvUZWOp1NcWC
[INFO] [connection: 1] << ACK_RECEIVED 60
[INFO] [connection: 2] << ACK_RECEIVED 60
[INFO] [process: 1] Process terminated (exited with code 2) and was restarted
[INFO] [connection: 1] Connection closed
[INFO] [connection: 3] New connection established
[INFO] [process: 2] Process terminated (exited with code 2) and was restarted
[INFO] [connection: 2] Connection closed
[INFO] [connection: 4] New connection established
[INFO] [connection: 4] >> 2024-07-06 02:19:30 nRcmv431bQ==
[INFO] [connection: 3] >> 2024-07-06 02:19:30 nRcmv431bQ==
[INFO] [stdin] Received: 2024-07-06 02:19:30 nRcmv431bQ==
[INFO] [connection: 4] << ACK_RECEIVED 32
[INFO] [connection: 3] << ACK_RECEIVED 32
[INFO] [connection: 3] << KEEP_ALIVE
[INFO] [connection: 3] >> KEEP_ALIVE_ACK
[INFO] [stdin] Received: 2024-07-06 02:19:35 269ystRIi8IxJEws
[INFO] [connection: 3] >> 2024-07-06 02:19:35 269ystRIi8IxJEws
[INFO] [connection: 4] >> 2024-07-06 02:19:35 269ystRIi8IxJEws
[INFO] [connection: 3] << ACK_RECEIVED 36
[INFO] [connection: 4] << ACK_RECEIVED 36
[INFO] [connection: 3] << KEEP_ALIVE
[INFO] [connection: 3] >> KEEP_ALIVE_ACK
[INFO] [connection: 4] << KEEP_ALIVE
[INFO] [connection: 4] >> KEEP_ALIVE_ACK
...
```
</details>
