defmodule Wanda.Messaging do
  @moduledoc """
  Publishes messages to the message bus
  """

  @spec publish(String.t(), any()) :: :ok | {:error, any()}
  def publish(topic, message) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** publish ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    #adapter().publish(topic, message)
  end

  #defp adapter,
  #  do: Application.fetch_env!(:wanda, :messaging)[:adapter]
end
