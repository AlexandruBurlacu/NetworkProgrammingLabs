defmodule Lab2 do
  @moduledoc """
  Documentation for Lab2.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Lab2.hello
      # a fuck lot of HTTP bodies here

  """
  def hello do
    service_root = "https://desolate-ravine-43301.herokuapp.com"
    resp = HTTPotion.post(service_root)
    {urls, key} = {Poison.decode!(resp.body), resp.headers["session"]}

    tasks = Enum.map(urls, fn url -> 
      Task.async(fn -> HTTPotion.get("#{service_root}#{url["path"]}",
                 headers: ["session": key]) end)
    end)
    :timer.sleep(29990)
    bodies = Enum.map(tasks, &Task.await(&1))

    bodies
  end

end
