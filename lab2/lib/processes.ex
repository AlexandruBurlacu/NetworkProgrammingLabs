defmodule Lab2.SecondTry do

    @service_root "https://desolate-ravine-43301.herokuapp.com"

    defp get_urls_and_key do
        resp = HTTPotion.post(@service_root)

        {Poison.decode!(resp.body), resp.headers["session"]}
    end

    def hello do
        current_process = self()
        {urls, key} = get_urls_and_key()

        IO.inspect urls

        Enum.each urls, &spawn_link(fn -> 
           send current_process, {:msg, &1}
        end)

        receive do
            {:msg, url} -> HTTPotion.get("#{@service_root}#{url["path"]}",
                           headers: ["session": key])
        end
    end

end
