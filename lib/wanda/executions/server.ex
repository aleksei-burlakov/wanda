defmodule Wanda.Executions.Server do
  @moduledoc """
  Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
  Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations.
  """

  @behaviour Wanda.Executions.ServerBehaviour

  use GenServer, restart: :transient

  alias Wanda.Executions.{
    Evaluation,
    Gathering,
    Result,
    State,
    Supervisor,
    Target
  }

  alias Wanda.{
    Catalog,
    Executions,
    Messaging
  }

  alias Wanda.EvaluationEngine

  require Logger

  @default_target_type "cluster"
  @default_timeout 5 * 60 * 1_000

  @doc """
  Starts a check execution.

  The checks are filtered leveraging the `env` and evaluating the `when` condition using a best-effort approach.
  If non-existing check IDs are provided inside a target, they will get filtered away.
  """
  @impl true
  def start_execution(execution_id, group_id, targets, target_type, env, config \\ []) do
    env = Map.put(env, "target_type", target_type)

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** start_execution ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    checks =
      targets
      |> Target.get_checks_from_targets()
      |> Catalog.get_checks(env)

    checks_ids = Enum.map(checks, & &1.id)

    targets =
      Enum.map(targets, fn %{checks: target_checks} = target ->
        %Target{target | checks: target_checks -- target_checks -- checks_ids}
      end)

    maybe_start_execution(execution_id, group_id, targets, checks, env, config)
  end

  @impl true
  def receive_facts(execution_id, group_id, agent_id, facts) do
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** #{__MODULE__}.receive_facts ***\n")
    IO.binwrite(file, "execution_id=#{execution_id |> inspect()}\n")
    IO.binwrite(file, "group_id=#{group_id |> inspect()}\n")
    IO.binwrite(file, "group_id via tuple=#{group_id |> via_tuple() |> inspect()}\n")
    IO.binwrite(file, "agent_id=#{agent_id |> inspect()}\n")
    IO.binwrite(file, "facts=#{facts |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    group_id |> via_tuple() |> GenServer.cast({:receive_facts, execution_id, agent_id, facts})
  end

  def start_link(opts) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** start_link ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    group_id = Keyword.fetch!(opts, :group_id)
    config = Keyword.get(opts, :config, [])

    GenServer.start_link(
      __MODULE__,
      %State{
        execution_id: Keyword.fetch!(opts, :execution_id),
        group_id: group_id,
        targets: Keyword.fetch!(opts, :targets),
        checks: Keyword.fetch!(opts, :checks),
        env: Keyword.fetch!(opts, :env),
        timeout: Keyword.get(config, :timeout, @default_timeout)
      },
      name: via_tuple(group_id)
    )
  end

  @impl true
  def init(%State{execution_id: execution_id} = state) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** init ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    Logger.debug("Starting execution: #{execution_id}", state: inspect(state))

    {:ok, state, {:continue, :start_execution}}
  end

  @impl true
  def handle_continue(
        :start_execution,
        %State{
          execution_id: execution_id,
          group_id: group_id,
          targets: targets,
          checks: checks,
          timeout: timeout
        } = state
      ) do
    engine = EvaluationEngine.new()

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle_continue ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    facts_gathering_requested =
      Messaging.Mapper.to_facts_gathering_requested(execution_id, group_id, targets, checks)

    execution_started = Messaging.Mapper.to_execution_started(execution_id, group_id, targets)

    Executions.create_execution!(execution_id, group_id, targets)

    :ok = Messaging.publish("results", execution_started)
    :ok = Messaging.publish("agents", facts_gathering_requested)

    Process.send_after(self(), :timeout, timeout)

    {:noreply, %State{state | engine: engine}}
  end

  @impl true
  def handle_cast(
        {:receive_facts, execution_id, agent_id, facts},
        %State{execution_id: execution_id, targets: targets} = state
      ) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle_cast ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    if Gathering.target?(targets, agent_id) do
      continue_or_complete_execution(state, agent_id, facts)
    else
      Logger.warning(
        "Received facts for agent #{agent_id} but it is not a target of this execution",
        facts: inspect(facts)
      )

      {:noreply, state}
    end
  end

  @impl true
  def handle_cast(
        {:receive_facts, execution_id, _, _},
        %State{group_id: group_id} = state
      ) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle_cast2 ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    Logger.error("Execution #{execution_id} does not match for group #{group_id}")

    {:noreply, state}
  end

  @impl true
  def handle_info(
        :timeout,
        %State{
          engine: engine,
          execution_id: execution_id,
          group_id: group_id,
          gathered_facts: gathered_facts,
          targets: targets,
          checks: checks,
          env: env,
          agents_gathered: agents_gathered
        } = state
      ) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle_info ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    targets =
      Enum.filter(targets, fn %Target{agent_id: agent_id} ->
        agent_id not in agents_gathered
      end)

    timedout_agents = Enum.map(targets, & &1.agent_id)

    gathered_facts = Gathering.put_gathering_timeouts(gathered_facts, targets)

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** handle_info ***\n")
    IO.binwrite(file, "gathered_facts=#{gathered_facts |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    result =
      Evaluation.execute(
        execution_id,
        group_id,
        checks,
        gathered_facts,
        env,
        timedout_agents,
        engine
      )

    store_and_publish_execution_result(result, env)

    {:stop, :normal, state}
  end

  defp continue_or_complete_execution(
         %State{
           engine: engine,
           execution_id: execution_id,
           group_id: group_id,
           gathered_facts: gathered_facts,
           targets: targets,
           checks: checks,
           env: env,
           agents_gathered: agents_gathered
         } = state,
         agent_id,
         facts
       ) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** #{__MODULE__}.continue_or_complete_execution BEFORE ***\n")
    IO.binwrite(file, "gathered_facts=#{gathered_facts |> inspect()}\n")
    IO.binwrite(file, "facts=#{facts |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    gathered_facts = Gathering.put_gathered_facts(gathered_facts, agent_id, facts)
    agents_gathered = [agent_id | agents_gathered]

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** #{__MODULE__}.continue_or_complete_execution AFTER ***\n")
    IO.binwrite(file, "gathered_facts=#{gathered_facts |> inspect()}\n")
    IO.binwrite(file, "facts=#{facts |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    state = %State{state | gathered_facts: gathered_facts, agents_gathered: agents_gathered}

    if Gathering.all_agents_sent_facts?(agents_gathered, targets) do
      result = Evaluation.execute(execution_id, group_id, checks, gathered_facts, env, engine)

      store_and_publish_execution_result(result, env)


      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  defp store_and_publish_execution_result(%Result{execution_id: execution_id} = result, env) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** store_and_publish_execution_result ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    Executions.complete_execution!(execution_id, result)

    target_type = Map.get(env, "target_type", @default_target_type)

    execution_completed = Messaging.Mapper.to_execution_completed(result, target_type)
    :ok = Messaging.publish("results", execution_completed)
  end

  defp via_tuple(group_id),
    do: {:via, :global, {__MODULE__, group_id}}

  defp maybe_start_execution(_, _, _, [], _, _), do: {:error, :no_checks_selected}

  defp maybe_start_execution(execution_id, group_id, targets, checks, env, config) do

    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** maybe_start_execution ***\n")
    IO.binwrite(file, "execution_id=#{execution_id |> inspect()}\n")
    IO.binwrite(file, "group_id=#{group_id |> inspect()}\n")
    IO.binwrite(file, "targets=#{targets |> inspect()}\n")
    IO.binwrite(file, "checks=#{checks |> inspect()}\n")
    IO.binwrite(file, "env=#{env |> inspect()}\n")
    IO.binwrite(file, "__MODULE__=#{__MODULE__ |> inspect()}\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)

    case DynamicSupervisor.start_child(
           Supervisor,
           {__MODULE__,
            execution_id: execution_id,
            group_id: group_id,
            targets: targets,
            checks: checks,
            env: env,
            config: config}
         ) do
      {:ok, _} ->
        :ok

      {:error, {:already_started, _}} ->
        {:error, :already_running}

      error ->
        error
    end
  end
end
