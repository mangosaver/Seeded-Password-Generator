defmodule PassManager.IpConnState do
  use Agent

  @max_reqs_per_period 3
  @period_ms 4_000

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Uses the IP address to look up a series of timestamps representing recent
  connections. If there are more than the specified number of requests within
  a certain period (i.e. more than x requests per y seconds), it returns false.
  If the request is valid, it returns true.
  """
  def update_map(ip_addr, timestamp) do
    if Agent.get(__MODULE__, &Map.has_key?(&1, ip_addr)) do
      prev_period = timestamp - @period_ms
      list = [timestamp | Agent.get(__MODULE__, &Map.get(&1, ip_addr))]
      Agent.update(__MODULE__, &Map.put(&1, ip_addr, list))
      if length(list) <= @max_reqs_per_period do
        true
      else
        in_last_period = for n <- list, n >= prev_period, do: n
        length(in_last_period) <= @max_reqs_per_period
      end
    else
      Agent.update(__MODULE__, &Map.put(&1, ip_addr, [timestamp]))
      true
    end
  end
end
