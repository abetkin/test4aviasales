
defmodule Message do
  defstruct [
    content: nil,
    history: [],
  ]

  @timeout 1000 * 60 # 60 sec

  def spawn(msg) do
    Kernel.spawn(__MODULE__, :run, [msg])
  end

  def run(msg) do
    try do
      receive do
        :ack -> :ok
        :reject -> on_error(msg, :reject)
      after @timeout ->
        on_error(msg, :timeout)
      end
    rescue
      e -> on_error(msg, e)
    end
  end

  defp on_error(msg, e) do
    new_m = %Message{msg | history: [e | msg.history]}
    Queue |> GenServer.cast({:add, new_m})
    :error
  end
end
