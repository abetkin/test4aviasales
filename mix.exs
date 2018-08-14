defmodule Message.MixProject do
  use Mix.Project

  def project do
    [
      app: :message,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Queue.Application, []}
    ]
  end

  defp deps do
    [
      {:gen_state_machine, "~> 2.0.2"}
    ]
  end

end
