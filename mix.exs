defmodule ReplayNginxLogs.MixProject do
  use Mix.Project

  def project do
    [
      app: :replay_nginx_logs,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex],
      mod: {ReplayNginxLogs, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.6"},
      {:ratatouille, "~> 0.5.0"},
      {:tesla, "~> 1.3.0"},
      {:jason, ">= 1.0.0"},
    ]
  end
end
