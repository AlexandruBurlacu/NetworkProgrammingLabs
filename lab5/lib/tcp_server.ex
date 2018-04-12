defmodule TCPServer do

    require Logger

    def accept(port) do
        # The options below mean:
        #
        # 1. `:binary` - receives data as binaries (instead of lists)
        # 2. `packet: :line` - receives data line by line
        # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
        # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
        #
        {:ok, socket} = :gen_tcp.listen(port,
                        [:binary, packet: :line, active: false, reuseaddr: true])
        Logger.info "Accepting connections on port #{port}"
        loop_acceptor(socket)
    end
    
    defp loop_acceptor(socket) do
        {:ok, client} = :gen_tcp.accept(socket)
        Task.start_link(fn -> serve(client) end)
        loop_acceptor(socket)
    end
    
    defp serve(socket) do
        socket
        |> read_line()
        |> write_line(socket)
    
        serve(socket)
    end
    
    defp read_line(socket) do
        {:ok, data} = :gen_tcp.recv(socket, 0)
        {status, log_msg} = arg_handler(data, socket)
        Logger.info log_msg
        data
    end
    
    defp write_line(line, socket) do
        :gen_tcp.send(socket, line)
    end

    defp arg_handler(data, socket) do
        case data do
            "exit\r\n" -> :gen_tcp.close socket
            _ -> {:ok, "Received #{data}"}
        end
    end
end