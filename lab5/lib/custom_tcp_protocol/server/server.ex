defmodule Lab5.CustomTCPProtocol.Server do
    @moduledoc """
    Sever side of the CustomTCPProtocol library

    :func: start
    """

    require Logger

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

        if verbose, do: Logger.info "Accepting connections on port #{port}"

        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        {:ok, client} = :gen_tcp.accept(socket)
        {:ok, pid} = Task.Supervisor.start_child(TCPServer.TaskSupervisor, fn -> IO.inspect(client) end) # serve(client)
        :ok = :gen_tcp.controlling_process(client, pid)
        loop_acceptor(socket)
    end
end
