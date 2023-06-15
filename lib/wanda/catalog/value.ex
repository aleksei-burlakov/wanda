defmodule Wanda.Catalog.Value do
  @moduledoc """
  Represents a value.
  """

  alias Wanda.Catalog.Condition

  @derive Jason.Encoder
  defstruct [:name, :default, :conditions]

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** Wanda.Catalog.Value.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @type t :: %__MODULE__{
          name: String.t(),
          default: boolean() | number() | String.t(),
          conditions: [Condition.t()]
        }
end
