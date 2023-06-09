defmodule Wanda.Executions.Target do
  @moduledoc """
  Execution targets.
  """

  defstruct [
    :agent_id,
    checks: []
  ]

  @type t :: %__MODULE__{
          agent_id: String.t(),
          checks: [String.t()]
        }

  @spec get_checks_from_targets([t()]) :: [String.t()]
  def get_checks_from_targets(targets) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** get_checks_from_targets ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    targets
    |> Enum.flat_map(& &1.checks)
    |> Enum.uniq()
  end

  def map_targets(map_list) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_targets ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Enum.map(map_list, fn %{agent_id: agent_id, checks: checks} ->
      %__MODULE__{agent_id: agent_id, checks: checks}
    end)
  end
end
