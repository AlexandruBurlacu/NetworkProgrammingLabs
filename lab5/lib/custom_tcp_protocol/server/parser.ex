defmodule Lab5.CustomTCPProtocol.Server.Parser do
    alias Lab5.CustomTCPProtocol.Server.Validation, as: Valiadion
    # import Valiadion

    def parse(expr) do
        with {:ok, expr} <- Valiadion.is_valid(expr),
        do: (
            {res, _ctx} = Code.eval_string expr
            {:ok, res}
        )
    end

end
