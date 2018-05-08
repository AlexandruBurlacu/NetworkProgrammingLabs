# # inspired from here
# # https://parroty00.wordpress.com/2013/07/28/elixir-tcp-server-example/
# defrecord LargeJob, name: "" do
#     def run(record) do
#         :timer.sleep(5000)
#         "Completed in 5 second(s) with param = #{record.name}"
#     end
# end

# defrecord SmallJob, name: "" do
#     def run(record) do
#         :timer.sleep(1000)
#         "Completed in 1 second(s) with param = #{record.name}"
#     end
# end

# defrecord InvalidJob, name: "" do
#     def run(_record) do
#         "Invalid command is specified"
#     end
# end

# defmodule Job do
#     def handle_request(sender, command) do
#         command = String.replace(command, "\r\n", "")
#         job = parse(String.split(command, " "))
#         sender <- {:ok, job.run()}
#     end

#     defp parse(["LARGE", name]) do
#         LargeJob.new name: name
#     end

#     defp parse(["SMALL", name]) do
#         SmallJob.new name: name
#     end

#     defp parse([_]) do
#         InvalidJob.new
#     end
# end

# defmodule Tcpserver do
#     def listen(port) do
#         tcp_options = [:list, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
#         {:ok, listen_socket} = :gen_tcp.listen(port, tcp_options)
#         do_listen(listen_socket)
#     end

#     defp do_listen(listen_socket) do
#         {:ok, socket} = :gen_tcp.accept(listen_socket)
#         spawn(fn() -> do_server(socket) end)
#         do_listen(listen_socket)
#     end

#     defp do_server(socket) do
#         case :gen_tcp.recv(socket, 0) do
#         {:ok, data} ->
#             responder = spawn(fn() -> do_respond(socket) end)
#             spawn(Job, :handle_request, [responder, list_to_binary(data)])
#             do_server(socket)

#         {:error, :closed} -> :ok
#         end
#     end

#     defp do_respond(socket) do
#         receive do
#         {:ok, response} ->
#             :gen_tcp.send(socket, "#{response}\n")
#             Logger.log(response)
#         end
#     end
# end