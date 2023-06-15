defmodule Wanda.Catalog.Check do
  @moduledoc """
  Represents a check.
  """

  alias Wanda.Catalog.{Expectation, Value}

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** Wanda.Catalog.Check.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :group,
    :description,
    :remediation,
    :severity,
    :facts,
    :values,
    :expectations,
    :when,
    :premium
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          group: String.t(),
          description: String.t(),
          remediation: String.t(),
          severity: :warning | :critical,
          facts: [Fact.t()],
          values: [Value.t()],
          expectations: [Expectation.t()],
          when: String.t(),
          premium: boolean()
        }
end
