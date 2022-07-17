defmodule PassManager.Router do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers,
      pass: ["*/*"],
      json_decoder: Jason,
      parsers: [:json]

  plug Plug.Static, at: "/pub", from: {:pass_manager, "priv/static/"}

  post "/gen", to: PassManager.GenPass

  plug :match
  plug :dispatch

  match _ do
    conn
    |> put_resp_header("location", "/pub/main.html")
    |> send_resp(308, "")
  end
end
