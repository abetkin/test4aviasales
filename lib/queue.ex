defmodule Queue do
  use GenServer

  defstruct [
    first: nil, # first to be processed, pid
    last: nil, # pid
  ]

  def add_message(content) do
    :ok = Queue |> GenServer.cast({:add_message, content})
  end

  def get() do
    Queue |> GenServer.call(:get)
  end

  def add_message(%Queue{first: nil, last: nil}, pid) do
    %Queue{first: pid, last: pid}
  end

  def add_message(%Queue{} = q, pid) do
    q.last |> GenServer.cast({:set_next, pid})
    case q.first do
      nil ->
        %Queue{q | last: pid, first: pid}
      _ ->
        %Queue{q | last: pid}
    end
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %Queue{}, name: Queue)
  end

    # Server

  def init(q) do
    {:ok, q}
  end

  def handle_cast({:add_message, content}, %Queue{} = q) do
    pid = new_message(content)
    new_q = q |> add_message(pid)
    {:noreply, new_q}
  end

  defp new_message(content) do
    message = %Message{content: content}
    {:ok, pid} = Message |> GenServer.start_link(message)
    pid
  end

  def handle_call(:get, _from, %Queue{first: nil} = q) do
    {:reply, nil, q}
  end

  def handle_call(:get, _from, %Queue{} = q) do
    first = q.first |> GenServer.call(:get)
    new_q = %Queue{q | first: first.next_message}
    {:reply, first, new_q}
  end

end
