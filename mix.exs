defmodule PassManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :pass_manager,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PassManager.App, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:jason, "~> 1.3"},
      {:plug_cowboy, "2.4.1"}
    ]
  end
end
