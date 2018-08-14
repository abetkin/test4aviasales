defmodule Queue.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Queue,
        start: {Queue, :start_link, []}
      }
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
