defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps domain structures to integration events.
  """

  alias Wanda.Catalog

  alias Wanda.Executions.{
    Fact,
    FactError,
    Result,
    Target
  }

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    ExecutionRequested,
    ExecutionStarted,
    FactRequest,
    FactsGathered,
    FactsGatheringRequested,
    FactsGatheringRequestedTarget
  }

  @spec to_execution_started(String.t(), String.t(), [Target.t()]) :: ExecutionStarted.t()
  def to_execution_started(execution_id, group_id, targets) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** to_execution_started ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    ExecutionStarted.new!(
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &map_target(&1))
    )
  end

  def to_facts_gathering_requested(execution_id, group_id, targets, checks) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** to_facts_gathering_requested ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    FactsGatheringRequested.new!(
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &to_facts_gathering_requested_target(&1, checks))
    )
  end

  def to_execution_completed(%Result{
        execution_id: execution_id,
        group_id: group_id,
        result: result
      }) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** to_execution_completed ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    ExecutionCompleted.new!(
      execution_id: execution_id,
      group_id: group_id,
      result: map_result(result)
    )
  end

  @spec from_execution_requested(ExecutionRequested.t()) :: %{
          execution_id: String.t(),
          group_id: String.t(),
          targets: [Target.t()],
          env: %{String.t() => boolean() | number() | String.t() | nil}
        }
  def from_execution_requested(%ExecutionRequested{
        execution_id: execution_id,
        group_id: group_id,
        targets: targets,
        env: env
      }) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** from_execution_requested ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    %{
      execution_id: execution_id,
      group_id: group_id,
      targets: Target.map_targets(targets),
      env: Map.new(env, fn {key, %{kind: value}} -> {key, map_env_entry(value)} end)
    }
  end

  @spec from_facts_gathererd(FactsGathered.t()) :: %{
          execution_id: String.t(),
          group_id: String.t(),
          agent_id: String.t(),
          facts_gathered: [Fact.t() | FactError.t()]
        }
  def from_facts_gathererd(%FactsGathered{
        execution_id: execution_id,
        group_id: group_id,
        agent_id: agent_id,
        facts_gathered: facts_gathered
      }) do  
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** from_facts_gathererd ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    %{
      execution_id: execution_id,
      group_id: group_id,
      agent_id: agent_id,
      facts_gathered:
        Enum.map(facts_gathered, fn %{check_id: check_id, name: name, fact_value: fact_value} ->
          map_gathered_fact(check_id, name, fact_value)
        end)
    }
  end

  defp map_target(%Target{agent_id: agent_id, checks: checks}) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_target ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Trento.Checks.V1.Target.new!(agent_id: agent_id, checks: checks)
  end

  defp to_facts_gathering_requested_target(
         %Target{agent_id: agent_id, checks: target_checks},
         checks
       ) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** to_facts_gathering_requested_target ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    fact_requests =
      checks
      |> Enum.filter(&(&1.id in target_checks))
      |> Enum.flat_map(fn %Catalog.Check{id: check_id, facts: facts} ->
        map_fact_requests(check_id, facts)
      end)

    FactsGatheringRequestedTarget.new!(agent_id: agent_id, fact_requests: fact_requests)
  end

  defp map_fact_requests(check_id, facts) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_fact_requests ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Enum.map(facts, fn %Catalog.Fact{name: name, gatherer: gatherer, argument: argument} ->
      FactRequest.new!(check_id: check_id, name: name, gatherer: gatherer, argument: argument)
    end)
  end

  defp map_result(:passing), do: :PASSING
  defp map_result(:warning), do: :WARNING
  defp map_result(:critical), do: :CRITICAL

  defp map_gathered_fact(check_id, name, {:error_value, %{type: type, message: message}}),
    do: %FactError{check_id: check_id, name: name, type: type, message: message}

  defp map_gathered_fact(check_id, name, {:value, value}),
    do: %Fact{check_id: check_id, name: name, value: map_value(value)}

  defp map_value(%{kind: {:list_value, %{values: values}}}) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_value ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Enum.map(values, &map_value/1)
  end

  defp map_value(%{kind: {:struct_value, %{fields: fields}}}) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_value2 ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Enum.into(fields, %{}, fn {key, value} -> {key, map_value(value)} end)
  end

  defp map_value(%{kind: {:number_value, value}}) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_value3 ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    truncated = trunc(value)
    if truncated == value, do: truncated, else: value
  end

  defp map_value(%{kind: {_, value}}) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** map_value4 ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    value
  end

  defp map_env_entry({_, value}), do: value
  defp map_env_entry({:null_value}), do: nil
end
