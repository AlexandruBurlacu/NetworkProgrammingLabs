defmodule Lab5.CustomTCPProtocol.Server.Validation do

    @regex ~r/([-+]?[0-9]*\.?[0-9]+[\/\+\-\*])+([-+]?[0-9]*\.?[0-9]+)/

    def is_valid(str) do
        if str =~ @regex do
            {:ok, str}
        else
            {:fail, "Invalid expression: #{str}"}
        end
    end

end
