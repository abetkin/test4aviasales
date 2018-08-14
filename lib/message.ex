defmodule Message do
  use GenServer

  defstruct [
    next_pid: nil, # in queue
    status: :created,
    content: nil,
    history: [],
  ]

  def set_status(%Message{} = m, new_status) do
    history = [m.status | m.history]
    %Message{m | history: history, status: new_status}
  end

  def start_link(message) do
    GenServer.start_link(__MODULE__, message)
  end

  def init(message) do
    {:ok, message}
  end

  def handle_cast({:set_next, pid}, %Message{status: :created} = m) do
    {:noreply, %Message{m | next_pid: pid}}
  end

  def handle_cast({:set_next, _pid}, %Message{} = m) do
    {:noreply, m} # no-op
  end

  def handle_call(:get, _from, %Message{} = m) do
    new_m = %Message{m | status: :processing}
    {:reply, m, new_m}
  end

  def handle_cast(:ack, %Message{status: :processing} = m) do
    new_m = %Message{m | status: :success}
    # Save to "the log"
    IO.inspect(new_m)
    {:stop, :normal, new_m}
  end

  def handle_cast(:reject, %Message{status: :processing} = m) do
    # Save to "the log"
    %Message{m | status: :error} |> IO.inspect
    history = [:error | m.history]
    new_m = %Message{m |
      status: :created,
      history: history,
      next_pid: nil,
    }
    {:noreply, new_m}
  end
end
