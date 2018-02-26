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
    {urls, key} = resp
    |> (fn x -> {Poison.decode!(x.body), x.headers["session"]} end).()

    bodies =
    # Task.async_stream(urls, fn x -> {
    #     HTTPotion.get("#{service_root}#{x["path"]}", headers: ["session": key])
    # } end, timeout: 15000)
    # # |> IO.inspect
    # # |> Enum.map((fn x -> x.body end).())
    # |> Enum.to_list

    Enum.map(urls, fn (x) -> {
      Task.async(HTTPotion.get("#{service_root}#{x["path"]}", headers: ["session": key]))
    } end)
    |> Enum.map((fn x -> Task.await(x, timeout: 30000) end).())
    |> Enum.to_list
    
    bodies
  end
end
