defmodule WandaWeb.V1.CatalogController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Wanda.Catalog
  alias WandaWeb.Schemas.CatalogResponse
  alias WandaWeb.Schemas.Env

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  # It's not clear, what exactly operation does,
  # it's only important that it exists.
  # I think it like declares that there is 'operation :catalog'
  # and the implementation of the 'operation :catalog' is in the 'def catalog'
  operation :catalog,
    hui: :mui
#    summary: "List checks catalog"
#    parameters: [
#      env: [
#        in: :query,
#        description: "env variables",
#        explode: true,
#        style: :form,
#        schema: Env
#      ]
#    ],
#    responses: [
#      ok: {"Check catalog response", "application/json", CatalogResponse},
#      unprocessable_entity: OpenApiSpex.JsonErrorResponse.response()
#    ]

  def catalog(conn, params) do
    # THIS IS THE PART WE NEED TO COPY TO THE CRMSH
    catalog = Catalog.get_catalog(params)

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.V1.CatalogController.catalog(conn, params)  ***\n")
    IO.binwrite(file, "catalog=#{catalog |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    render(conn, catalog: catalog)
  end
end
