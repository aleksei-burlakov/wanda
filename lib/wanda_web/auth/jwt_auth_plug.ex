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
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    authenticate(conn)
  end

  defp authenticate(conn) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.Auth.JWTAuthPlug.authenticate  ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    with {:ok, jwt_token} <- read_token(conn),
         {:ok, claims} <- AccessToken.verify_and_validate(jwt_token) do
      put_private(conn, :user_id, claims["sub"])
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Jason.encode!(%{error: "Unauthorized"}))
        |> halt()
    end
  end

  defp read_token(conn) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.Auth.JWTAuthPlug.read_tocken  ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    case get_req_header(conn, "authorization") do
      [bearer_token | _] ->
        token = bearer_token |> String.replace("Bearer", "") |> String.trim()
        {:ok, token}

      _ ->
        Logger.debug("No token found in request")

        {:error, :no_token}
    end
  end
end
