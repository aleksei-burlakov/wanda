defmodule WandaWeb.ApiSpec do
  @moduledoc false

  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.{Components, Info, OpenApi, Paths, SecurityScheme, Server}
  alias WandaWeb.{Endpoint, Router}

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** WandaWeb.ApiSpec.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @impl true
  def spec do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.ApiSpec.spec ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    # Discover request/response schemas from path specs
    OpenApiSpex.resolve_schema_modules(%OpenApi{
      servers: [
        endpoint()
      ],
      info: %Info{
        title: "Wanda",
        version: "1.0"
      },
      components: %Components{
        securitySchemes: %{"authorization" => %SecurityScheme{type: "http", scheme: "bearer"}}
      },
      security: [%{"authorization" => []}],
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router)
    })
  end

  defp endpoint do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.ApiSpec.endpoint ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    if Process.whereis(Endpoint) do
      # Populate the Server info from a phoenix endpoint
      Server.from_endpoint(Endpoint)
    else
      # If the endpoint is not running, use a placeholder
      # this happens when generarting openapi.json with --start-app=false
      # e.g. mix openapi.spec.json --start-app=false --spec WandaWeb.ApiSpec
      %OpenApiSpex.Server{url: "https://demo.trento-project.io"}
    end
  end
end
