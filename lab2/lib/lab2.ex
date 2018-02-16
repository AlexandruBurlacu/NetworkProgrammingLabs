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
    {status, urls} =
    HTTPotion.post(service_root)
    |> (fn x -> Poison.decode x.body end).()

    bodies =
    Task.async_stream(urls, fn x -> {
      case x["method"] do
        "GET" -> HTTPotion.get("#{service_root}#{x["path"]}").body
        "POST" -> HTTPotion.post("#{service_root}#{x["path"]}").body
        _ -> "It's complicated"
      end
    } end)
    |> Enum.to_list
    
    bodies
  end
end
