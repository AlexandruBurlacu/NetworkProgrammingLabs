defmodule Lab5.CustomTCPProtocol.Client do
    @moduledoc """
    Client side of the CustomTCPProtocol library

    :func: connect
    :func: exit
    :func: help
    :func: exec
    """

    def connect(port) do
        :gen_tcp.connect :localhost, port, [:binary, {:active, false}]
    end

    def help(socket) do
        fmsg = "/help\r\n"
        :gen_tcp.send socket, fmsg
        :gen_tcp.recv socket, 0
    end

    def exec(socket, msg) do
        fmsg = "/help " <> msg <> "\r\n"
        :ok = :gen_tcp.send socket, fmsg
        :gen_tcp.recv socket, 0
    end

    def exit(socket) do
        :ok = :gen_tcp.send socket, "/exit"
        status = :gen_tcp.close socket
        {:ok, "Connection closed"}
    end
    
end
