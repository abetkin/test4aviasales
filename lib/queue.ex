defmodule Queue do
  use GenServer

  defstruct [
    first: nil, # first to be processed, pid
    last: nil, # pid
  ]

  def add(content) do
    :ok = Queue |> GenServer.cast({:add, content})
  end

  def get() do
    Queue |> GenServer.call(:get)
  end

  def ack() do
    Queue |> GenServer.cast(:ack)
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

  def list(l, nil) when is_list(l) do
    Enum.reverse(l)
  end

  def list(l, current) when is_list(l) do
    m = current |> GenServer.call(:get)
    %Message{next_pid: new_current} = m
    list([m | l], new_current)
  end

  def list(%Queue{} = q) do
    list([], q.first)
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %Queue{}, name: Queue)
  end

    # Server

  def init(q) do
    {:ok, q}
  end

  def handle_cast({:add, content}, %Queue{} = q) do
    pid = create_message(content)
    new_q = q |> add_message(pid)
    {:noreply, new_q}
  end

  defp create_message(content) do
    message = %Message{content: content}
    {:ok, pid} = Message |> GenServer.start_link(message)
    pid
  end

  def handle_call(:get, _from, %Queue{first: nil} = q) do
    {:reply, nil, q}
  end

  def handle_call(:get, _from, %Queue{} = q) do
    first_msg = q.first |> GenServer.call(:get)
    new_q = %Queue{q | first: first_msg.next_pid}
    {:reply, {q.first, first_msg.content}, new_q}
  end

  def handle_cast({:ack, pid}, %Queue{} = q) do
    :ok = pid |> GenServer.cast(:ack)
    {:noreply, q}
  end

  def handle_cast({:reject, pid}, %Queue{} = q) do
    pid |> GenServer.cast(:reject)
    new_q = q |> add_message(pid)
    {:noreply, new_q}
  end

  def handle_call(:list, _from, %Queue{} = q) do
    {:reply, Queue.list(q), q}
  end

end
