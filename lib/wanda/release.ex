defmodule Wanda.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """

  @app :wanda

  def init do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** init ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    migrate()
  end

  def migrate do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** migrate ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** rollback ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp load_app do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** load_app ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Application.load(@app)
  end

  defp repos do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** repos ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Application.fetch_env!(@app, :ecto_repos)
  end
end
