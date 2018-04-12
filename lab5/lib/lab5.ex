defmodule Lab5 do

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

