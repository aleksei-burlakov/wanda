defmodule Wanda.Catalog.Condition do
  @moduledoc """
  Represents a condition.
  """

  @derive Jason.Encoder
  defstruct [:value, :expression]

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** Wanda.Catalog.Condition.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @type t :: %__MODULE__{
          value: boolean() | number() | String.t(),
          expression: String.t()
        }
end
