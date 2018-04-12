defmodule Lab5 do
  # Take a look
  # https://elixir-lang.org/getting-started/mix-otp/task-and-gen-tcp.html
  # http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/
  # https://parroty00.wordpress.com/2013/07/28/elixir-tcp-server-example/

  use GenServer

  @initial_state %{socket: nil}

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state)
  end

  def init(state) do
    start(nil, nil)
  end

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: TCPServer.TaskSupervisor},
      {Task, fn -> TCPServer.accept(4040) end}
    ]

    opts = [strategy: :one_for_one, name: TCPServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

