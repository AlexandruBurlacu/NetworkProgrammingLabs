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

    IO.inspect {urls, key}

    bodies =
    Task.async_stream(urls, fn x -> {
      case x["method"] do
        "GET" -> HTTPotion.get("#{service_root}#{x["path"]}", headers: ["session": key])
        _ -> "It's complicated"
      end
    } end)
    |> IO.inspect
    # |> Enum.map((fn x -> x.body end).())
    |> Enum.to_list
    
    bodies
  end
end
