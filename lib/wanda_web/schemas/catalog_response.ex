defmodule WandaWeb.Schemas.CatalogResponse do
  @moduledoc """
  Checks catalog response API spec
  """

  alias OpenApiSpex.Schema
  alias WandaWeb.Schemas.CatalogResponse.Check

  require OpenApiSpex


  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** WandaWeb.Schemas.CatalogResponse.CLASS_INITIALISATION  ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)

  OpenApiSpex.schema(%{
    title: "CatalogResponse",
    description: "Checks catalog listing response",
    type: :object,
    properties: %{
      items: %Schema{type: :array, description: "List of catalog checks", items: Check}
    }
  })
end
