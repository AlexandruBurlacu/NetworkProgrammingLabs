defmodule Lab5.CustomTCPProtocol.Logger do

    def log(message) do
        {{year, month, day}, {hour, min, sec}} = :erlang.localtime
        IO.puts "#{year}/#{month}/#{day} #{hour}:#{min}:#{sec} #{message}"
    end

end
