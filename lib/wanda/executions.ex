defmodule Wanda.Executions do
  @moduledoc """
  This module exposes functionalities to interact with the historycal log of executions.
  """

  import Ecto.Query

  alias Wanda.Repo

  alias Wanda.Executions.{
    Execution,
    Result,
    Target
  }

  @doc """
  Create a new execution.

  If the execution already exists, it will be returned.
  """
  @spec create_execution!(String.t(), String.t(), [Target.t()]) :: Execution.t()
  def create_execution!(execution_id, group_id, targets) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** create_execution! ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    %Execution{}
    |> Execution.changeset(%{
      execution_id: execution_id,
      group_id: group_id,
      status: :running,
      targets: Enum.map(targets, &Map.from_struct/1)
    })
    |> Repo.insert!(on_conflict: :nothing)
  end

  @doc """
  Get an execution by execution_id.
  """
  @spec get_execution!(String.t()) :: Execution.t()
  def get_execution!(execution_id) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** get_execution! ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Repo.get!(Execution, execution_id)
  end

  @doc """
  Get the last execution of a group by group_id.
  """
  @spec get_last_execution_by_group_id!(String.t()) :: Execution.t()
  def get_last_execution_by_group_id!(group_id) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** get_execution_by_group_id! ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Execution
    |> last(:started_at)
    |> where(group_id: ^group_id)
    |> Repo.one!()
  end

  @doc """
  Get a paginated list of executions.

  Can be filtered by group_id.
  """
  @spec list_executions(map()) :: [Execution.t()]
  def list_executions(params \\ %{}) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** list_executions ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    page = Map.get(params, :page, 1)
    items_per_page = Map.get(params, :items_per_page, 10)
    group_id = Map.get(params, :group_id)

    offset = (page - 1) * items_per_page

    from(e in Execution)
    |> maybe_filter_by_group_id(group_id)
    |> limit([_], ^items_per_page)
    |> offset([_], ^offset)
    |> order_by(desc: :started_at)
    |> Repo.all()
  end

  @doc """
  Counts executions in the database.
  """
  @spec count_executions(map()) :: non_neg_integer()
  def count_executions(params) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** count_executions ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    group_id = Map.get(params, :group_id)

    from(e in Execution)
    |> maybe_filter_by_group_id(group_id)
    |> select([e], count())
    |> Repo.one()
  end

  @doc """
  Marks a previously started execution as completed
  """
  @spec complete_execution!(String.t(), Result.t()) ::
          Execution.t()
  def complete_execution!(execution_id, %Result{} = result) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** complete_execution! ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Execution
    |> Repo.get!(execution_id)
    |> Execution.changeset(%{
      result: result,
      status: :completed,
      completed_at: DateTime.utc_now()
    })
    |> Repo.update!()
  end

  @spec maybe_filter_by_group_id(Ecto.Query.t(), String.t()) :: Ecto.Query.t()
  defp maybe_filter_by_group_id(query, nil), do: query

  defp maybe_filter_by_group_id(query, group_id),
    do: from(e in query, where: [group_id: ^group_id])
end
