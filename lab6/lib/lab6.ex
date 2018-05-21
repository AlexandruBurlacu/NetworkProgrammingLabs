defmodule Lab6 do
    @moduledoc """
    Documentation for Lab6.
    """

    def send_msg(user_msg, to, from) do
        msg = :base64.encode "{:type :chat, :txt \"#{msg}\"}"
        timestamp = :os.system_time(:milli_seconds)
        from_uuid = from
        to_uuid = to
        data = "#{timestamp}|#{from_uuid}|#{to_uuid}|#{msg}"
               |> :base64.encode
               |> String.to_charlist
               |> :erlang.term_to_binary

        {:ok, sock} = :gen_udp.open 61616, [:binary]
        :ok = :gen_udp.send(conn, 'localhost', 42424, data)
        :gen_udp.close(sock)
    end

    def create_user(name) do
        msg = :base64.encode "{:type :online, :username \"#{name}\"}"
        timestamp = :os.system_time(:milli_seconds)
        uuid = 

        data = "#{timestamp}|#{uuid}|:all|#{msg}"
               |> :base64.encode
               |> String.to_charlist
               |> :erlang.term_to_binary

        {:ok, sock} = :gen_udp.open 61615, [:binary]
        :ok = :gen_udp.send(conn, 'localhost', 42424, data)
        :gen_udp.close(sock)
    end
end
