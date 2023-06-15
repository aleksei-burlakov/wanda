defmodule WandaWeb.V1.CatalogView do
  use WandaWeb, :view

  alias Wanda.Catalog.Check


  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** WandaWeb.V1.CatalogView.CLASS_INITIALISATION  ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)

  def render("catalog.json", %{catalog: catalog}) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.V1.CatalogView.render(catalog.json, %{catalog: catalog})  ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    %{items: render_many(catalog, WandaWeb.V1.CatalogView, "check.json", as: :check)}
  end

  def render("check.json", %{check: %Check{} = check}) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** WandaWeb.V1.CatalogView.render(check.json, %{check: %Check{} = check})  ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    check
  end
end
