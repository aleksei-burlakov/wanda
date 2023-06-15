defmodule WandaWeb.Schemas.Env do
  @moduledoc false

  alias OpenApiSpex.Schema

  require OpenApiSpex


  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** WandaWeb.Schemas.Env.CLASS_INITIALISATION  ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)

  OpenApiSpex.schema(
    %{
      title: "ExecutionEnv",
      description: "Contextual Environment for the current execution",
      type: :object,
      additionalProperties: %Schema{
        oneOf: [
          %Schema{type: :string},
          %Schema{type: :integer},
          %Schema{type: :boolean},
          %Schema{type: :array, items: __MODULE__}
        ]
      }
    },
    struct?: false
  )
end
