defmodule Lab2.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab2,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpotion]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:excoveralls, github: "parroty/excoveralls", only: :test},
      {:poison, "~> 3.1"},
      {:httpotion, "~> 3.1.0"}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Alexandru Burlacu"],
      links: %{"GitHub" => "https://github.com/AlexandruBurlacu/NetworkProgrammingLabs/lab2"}
    }
  end
end
