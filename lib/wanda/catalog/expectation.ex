defmodule Wanda.Catalog.Expectation do
  @moduledoc """
  Represents an expectation.
  """

  @derive Jason.Encoder
  defstruct [:name, :type, :expression, :failure_message]

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** Wanda.Catalog.Expectation.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @type t :: %__MODULE__{
          name: String.t(),
          type: :expect | :expect_same,
          expression: String.t(),
          failure_message: String.t()
        }
end
