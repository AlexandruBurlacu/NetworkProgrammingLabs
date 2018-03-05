defmodule Lab2 do
    @moduledoc """
    Documentation for Lab2.

    http://www.theerlangelist.com/article/beyond_taskasync

    curl -X POST -v "https://desolate-ravine-43301.herokuapp.com"
    |& grep Session
    | xargs -I @ echo @' '
    | xargs -I {} curl -X GET -H "{}" -v https://desolate-ravine-43301.herokuapp.com/lab/slow

    """

    @doc """
    Hello world.

    ## Examples

        iex> Lab2.hello
        # a fuck lot of HTTP bodies here

    """

    @service_root "https://desolate-ravine-43301.herokuapp.com"

    defp get_urls_and_key do
        resp = HTTPotion.post(@service_root)

        {Poison.decode!(resp.body), resp.headers["session"]}
    end

    def hello do
        
        {urls, key} = get_urls_and_key()

        IO.inspect urls

        # data = Task.async(fn -> HTTPotion.get("#{service_root}/ofzvwicmsn",
        #              headers: ["session": key]) end)

        # Task.await(data, 30001).body

        tasks = Enum.map(urls, fn url -> 
          Task.async(fn -> HTTPotion.get("#{@service_root}#{url["path"]}",
                      headers: ["session": key]) end)
        end)
        # :timer.sleep(29990)
        bodies = Enum.map(tasks, &Task.await(&1))

        # bodies = Task.async_stream(urls, fn url -> HTTPotion.get("#{service_root}#{url["path"]}",
        #                                  headers: ["session": key]) end, timeout: 50000)
        # |> Enum.to_list

        bodies
    end

end
