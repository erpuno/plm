defmodule KVS.Index do
  require NITRO
  require KVS
  require Logger

  def parse(_), do: []

  def event(:init) do
      :io.format '~p', [:hello]
      [:user, :writers, :session, :enode]
      |> Enum.map(fn x ->
       [ :nitro.clear(x),
         send(self(), {:direct, x})] end)
  end

  def event(:user),
  do: :nitro.update(:user,
      NITRO.span(body: parse(:n2o.user())))

  def event(:session),
  do: :nitro.update(:session,
      NITRO.span(body: :n2o.sid()))

  def event(:enode),
  do: :nitro.update(:enode,
      NITRO.span(body: :nitro.compact(:erlang.node())))

  def event({:link, i}),
  do: [
      :nitro.clear(:feeds),
      :kvs.feed(i) |> Enum.map(fn t ->
        :nitro.insert_bottom(:feeds,
          NITRO.panel(body: :nitro.compact(t))) end)
    ]

  def event(:writers),
    do:
      :writer
      |> :kvs.all()
      |> :lists.sort()
      |> Enum.map(fn KVS.writer(id: i, count: c) ->
        :nitro.insert_bottom(
          :writers,
          NITRO.panel(body:
          [NITRO.link(body: i, postback: {:link, i}),
           ' (' ++ :nitro.to_list(c) ++ ')']))
      end)

  def event(_), do: []

  def ram(os), do: :nitro.compact(os)
end
