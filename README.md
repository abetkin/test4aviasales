Приложение представляет собой GenServer (`Queue`), состоянием которой является очередь сообщений
(структура `Qex`). Сообщение (структура `Message`) содержит поля `content` и `history` (история обработки).

```elixir
iex(1)> Queue.add("hey")
:ok
iex(2)> Queue.add("you")
:ok
iex(3)> Queue |> :sys.get_state
#Qex<[
  %Message{content: "hey", history: []},
  %Message{content: "you", history: []}
]>
```

Получить из очереди сообщение для обработки можно с помощью `Queue.get`:

```elixir
iex(4)> Queue.get
{#PID<0.195.0>, "hey"}
```

Ответ содержит pid процесса, которому нужно отправить результат обработки, и текст сообщения. Если процессу было отправлено `:ack`, он просто завершается.

```elixir
iex(5)> pid(0,195,0) |> send(:ack)
:ack
iex(6)> Queue |> :sys.get_state
#Qex<[
  %Message{content: "you", history: []},
]>
```

В других случаях он возвращает свое сообщение в очередь и тоже завершается.

```elixir
iex(7)> pid(0,180,0) |> send(:reject)
:reject
iex(8)> Queue |> :sys.get_state
#Qex<[%Message{content: "you", history: [:reject]}]>
```

Была использована библиотека [Qex](https://github.com/princemaple/elixir-queue)