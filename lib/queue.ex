
defmodule Queue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, Qex.new(), name: Queue)
  end

  def add(msg) do
    Queue |> GenServer.cast({:add, msg})
  end

  def get() do
    Queue |> GenServer.call(:get)
  end

  def init(q) do
    {:ok, q}
  end

  def handle_cast({:add, msg}, q) do
    msg =
      case msg do
        %Message{} -> msg
        _ -> %Message{content: msg}
      end

    new_q = q |> Qex.push(msg)
    {:noreply, new_q}
  end

  def handle_call(:get, _from, q) do
    {{:value, m}, new_q} = q |> Qex.pop()
    pid = Message.spawn(m)
    {:reply, {pid, m.content}, new_q}
  end

end
