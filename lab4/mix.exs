defmodule Lab4.MixProject do
  use Mix.Project

  def project do
    [
      app: :mailapp,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :bamboo, :bamboo_smtp]
    ]
  end

  defp deps do
    [
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4.0"}
    ]
  end
end
