defmodule WandaWeb.Auth.AccessToken do
  @moduledoc """
    Jwt Token is the module responsible for creating a proper jwt access token.
    Uses Joken as jwt base library
  """

  use Joken.Config, default_signer: :access_token_signer

  @iss "https://github.com/trento-project/web"
  @aud "trento-project"

  @impl true
  def token_config do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** tocken_config ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    default_claims(iss: @iss, aud: @aud)
  end
end
