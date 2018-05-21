defmodule Lab6 do
    @moduledoc """
    Documentation for Lab6.
    """

    defp send_udp(data) do
        {:ok, sock} = :gen_udp.open 0, []
        :ok = :gen_udp.send(sock, '230.185.192.108', 42424, data)
        :gen_udp.close(sock)
    end

    def send_msg(user_msg, from_uuid, to_uuid) do
        msg = :base64.encode "{:type :chat, :txt \"#{user_msg}\"}"
        timestamp = :os.system_time(:milli_seconds)
        data = "#{timestamp}|#{from_uuid}|#{to_uuid}|#{msg}"
               |> :base64.encode
            #    |> String.to_charlist
            #    |> :erlang.term_to_binary

        send_udp data
    end

    def create_user(name) do
        msg = :base64.encode "{:type :online, :username \"#{name}\"}"
        timestamp = :os.system_time(:milli_seconds)
        uuid = UUID.uuid4()

        data = "#{timestamp}|#{uuid}|:all|#{msg}"
               |> :base64.encode
            #    |> String.to_charlist
            #    |> :erlang.term_to_binary

        send_udp data

        uuid
    end
end
