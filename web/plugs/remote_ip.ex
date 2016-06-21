@doc """
Formats the remote IP address from the `conn` struct to a string and assigns it
"""
defmodule EdmBackend.RemoteIp do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    remote_ip = conn.remote_ip |> Tuple.to_list
    if length(remote_ip) == 4 do
        assign(conn, :remote_ip, remote_ip |> Enum.join("."))
      else
        assign(conn, :remote_ip, remote_ip |> Enum.join(":"))
    end
  end
end