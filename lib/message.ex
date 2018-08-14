defmodule Message do
  use GenServer

  defstruct [
    status: :created,
    content: nil,
    history: [],
    next_message: nil, # in queue
  ]

  def set_status(%Message{} = m, new_status) do
    history = [m.status | m.history]
    %Message{m | history: history, status: new_status}
  end


  def start_link(message) do
    # function is a part of the child spec, to be used by the supervisor
    GenServer.start_link(__MODULE__, message)
  end

  def init(message) do
    {:ok, message}
  end

  def handle_cast({:set_next, pid}, %Message{} = m) do
    {:noreply, %Message{m | next_message: pid}}
  end
end
