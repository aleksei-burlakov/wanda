defmodule Wanda.Messaging.Adapters.AMQP.Publisher do
  @moduledoc """
  AMQP publisher.
  """

  @behaviour GenRMQ.Publisher

  alias Trento.Contracts

  require Logger

  def init do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** Publisher.init ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Application.fetch_env!(:wanda, Wanda.Messaging.Adapters.AMQP)[:publisher]
  end

  def start_link(_opts), do: GenRMQ.Publisher.start_link(__MODULE__, name: __MODULE__)

  def publish_message(message, routing_key \\ "") do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** Publisher.publish_message  ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    Logger.info("Publishing message #{inspect(message)}")

    GenRMQ.Publisher.publish(__MODULE__, message, routing_key, [
      {:content_type, Contracts.content_type()}
    ])
  end

  def child_spec(opts) do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** Publisher.child_spec ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
