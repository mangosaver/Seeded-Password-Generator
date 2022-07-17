defmodule PassManager.GenPass do
  use Agent
  import Plug.Conn

  @min_pass_len 12
  @min_site_len 4
  @salt_len 29

  def init(options), do: options

  @doc """
  Logs the user's request timestamp in a map, and checks to see if the user
  is within the rate limit. If not, "wait" is returned in the HTTP response.
  If the request is valid, the hashed password is generated and returned.
  """
  def call(conn, _opts) do
    timestamp = :os.system_time(:millisecond)
    ip_addr = ip2str(conn.remote_ip)

    valid = PassManager.IpConnState.update_map(ip_addr, timestamp)

    if !valid do
      conn
      |> send_resp(400, "wait")
    else
      pass = conn.params["master"]
      siteUrl = conn.params["url"]

      if !valid_str(pass, @min_pass_len) || !valid_str(siteUrl, @min_site_len) do
        conn
        |> send_resp(400, "error")
      else
        combined = pass <> siteUrl
        salt = PassManager.SaltManager.get_salt()
        hashed = Bcrypt.Base.hash_password(combined, salt)
        output = String.slice(hashed, @salt_len..(@salt_len + 31))
        conn
        |> send_resp(200, output)
      end
    end
  end

  _ = """
  Utility function to convert an IP address tuple into a "normal" string.
  E.g. {127, 0, 0, 1} -> "127.0.0.1"
  """
  defp ip2str(ip_tuple), do: ip_tuple |> Tuple.to_list |> Enum.join(".")

  _ = """
  Ensures that a string is non-nil and of a valid specified length.
  """
  defp valid_str(str, minLen), do: str != nil && String.length(str) >= minLen

end
