defmodule Lab5.CustomTCPProtocol.Server do
    @moduledoc """
    Sever side of the CustomTCPProtocol library

    :func: start
    """

    alias Lab5.CustomTCPProtocol.Logger, as: Logger
    require Logger

    @regex ~r/([-+]?[0-9]*\.?[0-9]+[\/\+\-\*])+([-+]?[0-9]*\.?[0-9]+)/

    @doc """
        The options below mean:
    
    1. `:binary` - receives data as binaries (instead of lists)
    2. `packet: :line` - receives data line by line
    3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    
    """

    def start(port, verbose \\ false) do
        {:ok, socket} = :gen_tcp.listen(port,
        [:binary, packet: :line, active: false, reuseaddr: true])

        if verbose, do: Logger.log "Accepting connections on port #{port}"

        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        {:ok, client} = :gen_tcp.accept(socket)
        {:ok, pid} = Task.Supervisor.start_child(Lab5.CustomTCPProtocol.Server.TaskSupervisor, fn -> serve(client) end)
        :ok = :gen_tcp.controlling_process(client, pid)
        loop_acceptor(socket)
    end

    defp serve(socket) do
        socket
        |> get_request()
        |> check_closed()
        |> drop_status()
        |> respond(socket)
    
        serve(socket)
    end

    defp drop_status({_status, msg}) do
        msg
    end

    defp check_closed(line) do
        {status, _msg} = line
        case status do
            :error -> exit 0
            :ok -> line
        end
    end
    
    defp get_request(socket) do
        {:ok, data} = :gen_tcp.recv(socket, 0)
        {status, log_msg} = arg_handler(data, socket)
        Logger.log log_msg
        {status, log_msg}
    end
    
    defp respond(data, socket) do
        :gen_tcp.send(socket, data)
    end

    defp exit_request_handler(socket) do
        resp = :gen_tcp.close(socket)
        case resp do
            :ok -> {:ok, "Connection closed"}
            _   -> {:error, "Some nasty shit happened"}
        end
    end

    defp help_request_handler do
        {:ok, "How can I help you?"}
    end

    defp extract_expr(data) do
        [head | _] = Regex.run @regex, data
        head
    end

    defp exec_request_handler(expr) do
        {result, _ctx} = Code.eval_string expr
        result_str = cond do
            is_float result -> Float.to_string result
            is_integer result -> Integer.to_string result
        end
        {:ok, result_str}
    end

    defp complex_condition(data) do
        data =~ @regex and String.starts_with? data, "/exec"
    end

    defp arg_handler(data, socket) do
        cond do
            data == "/exit\r\n" -> exit_request_handler(socket)
            data == "/help\r\n" -> help_request_handler()
            complex_condition data -> data |> extract_expr |> exec_request_handler
            true -> {:ok, "Received #{data}"}
        end
    end
end
