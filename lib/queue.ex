defmodule Queue do
  defstruct [
    first: nil, # first to be processed, pid
    last: nil, # pid

  ]

  use GenServer

  def add_message(content) do
    :ok = Queue |> GenServer.cast({:add_message, content})
  end

  def handle_cast({:add_message, content}, %Queue{} = q) do
    pid = new_message(content)
    new_q = case q.last do
      nil ->
        nil = q.first
        %Queue{first: pid, last: pid}
      _ ->
        q.last |> GenServer.cast({:set_next, pid})
        %Queue{q | last: pid}
    end
    {:noreply, new_q}
  end

  defp new_message(content) do
    message = %Message{content: content}
    {:ok, pid} = Message.Supervisor |> DynamicSupervisor.start_child(%{
      id: Message,
      start: {Message, :start_link, [message]},
    })
    pid
  end

    def start_link() do
      # function is a part of the child spec, to be used by the supervisor
      GenServer.start_link(__MODULE__, %Queue{}, name: Queue)
    end

    # Server

    def init(q) do
      {:ok, q}
    end

end
