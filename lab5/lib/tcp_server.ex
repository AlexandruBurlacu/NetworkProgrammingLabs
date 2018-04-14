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
        |> check_closed()
        |> write_line(socket)
    
        serve(socket)
    end

    defp check_closed(line) do
        case line do
            "Connection closed" -> exit 0
            _ -> line
        end
    end
    
    defp read_line(socket) do
        {:ok, data} = :gen_tcp.recv(socket, 0)
        {:ok, log_msg} = arg_handler(data, socket)
        Logger.info log_msg
        log_msg
    end
    
    defp write_line(line, socket) do
        :gen_tcp.send(socket, line)
    end

    defp close_conn(socket) do
        resp = :gen_tcp.close(socket)
        case resp do
            :ok -> {:ok, "Connection closed"}
            _   -> {:error, "Some bad shit happened"}
        end
    end

    defp arg_handler(data, socket) do
        cond do
            data == "/exit\r\n" -> close_conn(socket)
            data == "/help\r\n" -> {:ok, "Hello World"}
            String.match? data, ~r"/help \w+\r\n" -> {:ok, "Hello World"}
            true -> {:ok, "Received #{data}"}
        end
    end
end