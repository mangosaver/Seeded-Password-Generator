defmodule PassManager.App do
  use Application

  @port 4000

  def start(_type, _args) do
    IO.puts("Starting server...")

    children = [
      PassManager.SaltManager,
      PassManager.IpConnState,
      Plug.Cowboy.child_spec(scheme: :http, plug:
      PassManager.Router, options: [port: @port])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
