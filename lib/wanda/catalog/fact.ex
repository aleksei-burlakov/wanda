defmodule Wanda.Catalog.Fact do
  @moduledoc """
  Represents a fact.
  """

  @derive Jason.Encoder
  defstruct [:name, :gatherer, :argument]

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** Wanda.Catalog.Fact.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @type t :: %__MODULE__{
          name: String.t(),
          gatherer: String.t(),
          argument: String.t()
        }
end
