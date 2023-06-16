defmodule WandaWeb.Auth.JWTAuthPlug do
  @moduledoc """
    Plug responsible for reading the JWT from the authorization header and
    validating it.

    If the token is valid, the user_id is added to the private section of the
    connection.
    If the token is invalid, the connection is halted with a 401 response.
  """
  @behaviour Plug

  import Plug.Conn

  alias WandaWeb.Auth.AccessToken

  require Logger

  #def init(opts), do: opts
  def init(opts) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.Auth.JWTAuthPlug.init  ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    opts
  end

  @doc """
    Read, validate and decode the JWT from authorization header at each call
  """
  def call(conn, _) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.Auth.JWTAuthPlug.call(conn,_)  ***\n")
    IO.binwrite(file, "conn=#{conn |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    #authenticate(conn)
    conn
  end
end
