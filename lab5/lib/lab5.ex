defmodule Lab5 do
    # Take a look
    # https://elixir-lang.org/getting-started/mix-otp/task-and-gen-tcp.html
    # http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

    use GenServer

    @initial_state %{socket: nil}

    def start_link do
        GenServer.start_link(__MODULE__, @initial_state)
    end

    def init(state \\ @initial_state) do
        children = [
            {Task.Supervisor, name: Lab5.CustomTCPProtocol.Server.TaskSupervisor},
            Supervisor.child_spec({Task, fn -> Lab5.CustomTCPProtocol.Server.start(4040) end}, restart: :permanent)
        ]

        opts = [strategy: :one_for_one, name: Lab5.CustomTCPProtocol.Server.Supervisor]
        Supervisor.start_link(children, opts)    
    end
end
