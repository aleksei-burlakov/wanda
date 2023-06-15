defmodule Wanda.Policy do
  @moduledoc """
  Handles integration events.
  """

  alias Trento.Checks.V1.{
    ExecutionRequested,
    FactsGathered
  }

  alias Wanda.Messaging.Mapper

  require Logger

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** Wanda.Policy.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  @spec handle_event(ExecutionRequested.t() | FactsGathered.t()) :: :ok | {:error, any}
  def handle_event(event) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle_event ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Logger.debug("Handling event #{inspect(event)}")

    handle(event)
  end

  defp handle(%ExecutionRequested{} = message) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    %{execution_id: execution_id, group_id: group_id, targets: targets, env: env} =
      Mapper.from_execution_requested(message)

    execution_server_impl().start_execution(
      execution_id,
      group_id,
      targets,
      env
    )
  end

  defp handle(%FactsGathered{} = message) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle2 ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    %{
      execution_id: execution_id,
      group_id: group_id,
      agent_id: agent_id,
      facts_gathered: facts_gathered
    } = Mapper.from_facts_gathererd(message)

    execution_server_impl().receive_facts(
      execution_id,
      group_id,
      agent_id,
      facts_gathered
    )
  end

  defp execution_server_impl do
 
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** Wanda.Policy.execution_server_impl ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Application.fetch_env!(:wanda, Wanda.Policy)[:execution_server_impl]
  end
end
