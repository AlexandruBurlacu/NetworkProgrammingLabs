defmodule Lab2 do
    @moduledoc """
    Documentation for Lab2.

    Those awful timeouts...

    """

    @service_root "https://desolate-ravine-43301.herokuapp.com"

    defp get_urls_and_key do
        resp = HTTPotion.post(@service_root)

        {Poison.decode!(resp.body), resp.headers["session"]}
    end

    defp parse({cont_t, content}) do
        case cont_t do
            "text/csv" -> content
                          |> NimbleCSV.RFC4180.parse_string
                          |> Enum.map(fn [d_id, s_t, v] -> %{
                                            "device_id" => d_id,
                                            "sensor_type" => String.to_integer(s_t),
                                            "value" => String.to_float(v)
                                        } end)
            "Application/json" -> Poison.decode! content
            "Application/xml" -> content
            "text/plain; charset=utf-8" -> IO.puts content
        end
    end

    @doc """
    ## Examples

        iex> Lab2.get_body_and_conttype(%HTTPotion.Response{
        iex>    body: "<device id='oflpvssiaykbk'><type>5</type><value>0.48594528</value></device>",
        iex>    headers: %HTTPotion.Headers{
        iex>    hdrs: %{
        iex>         "content-type" => "Application/xml",
        iex>        "date" => "Thu, 08 Mar 2018 09:42:41 GMT",
        iex>         "server" => "Cowboy",
        iex> }}})
        {"Application/xml", "<device id='oflpvssiaykbk'><type>5</type><value>0.48594528</value></device>"}

    """
    def get_body_and_conttype(resp) do
        {resp.headers.hdrs["content-type"], resp.body}
    end

    def fetch do
        
        {urls, key} = get_urls_and_key()

        urls
        |> Enum.map(fn url ->
                Task.async(fn ->
                    HTTPotion.get "#{@service_root}#{url["path"]}",
                                  [headers: ["session": key],
                                   timeout: 50_000]
                end)
            end)
        |> Enum.map(&Task.await(&1, 50_000))
        |> Enum.map(&get_body_and_conttype(&1))
        |> Enum.map(&parse(&1))
        |> List.flatten
    end

end
