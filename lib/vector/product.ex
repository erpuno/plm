defmodule PLM.Rows.Product do
  require N2O
  require FORM
  require NITRO
  require ERP
  require Logger
  require Record

  def doc(),
    do: "PLM product."

  def id(), do: ERP."Product"(id: 'NYNJA')
  def mul({:money, a, b}, {:money, c, d}), do: {:money, a + c, b * d}

  def sum(feed) do
    {_, b} =
      :lists.foldl(
        fn ERP."Payment"(volume: v, price: p), {x, y} ->
          {:money, _, y1} = mul(v, p)
          {x, y + y1}
        end,
        {0, 0},
        :kvs.all(feed)
      )

    b
  end

  def new(name, prod, _) do
    id = ERP."Product"(prod, :id)
    income = ('/plm/' ++ id ++ '/income') |> sum
    outcome = ('/plm/' ++ id ++ '/outcome') |> sum
    feed = '/fin/acc/' ++ id
    {:ok, ERP."Acc"(rate: {:money, _, rnd})} = :kvs.get(feed ++ '/R&D', id ++ '/R&D')
    {:ok, ERP."Acc"(rate: {:money, _, ins})} = :kvs.get(feed ++ '/insurance', id ++ '/insurance')
    {:ok, ERP."Acc"(rate: {:money, _, opt})} = :kvs.get(feed ++ '/options', id ++ '/options')
    {:ok, ERP."Acc"(rate: {:money, _, rsv})} = :kvs.get(feed ++ '/reserved', id ++ '/reserved')

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(
          class: :column6,
          body: NITRO.link(href: 'cashflow.htm?p=' ++ id, body: id)
        ),
        NITRO.panel(
          class: :column6,
          body:
            "Total Income: " <>
              :nitro.to_binary(income) <>
              "<br>" <>
              "Gross Profit: " <>
              :nitro.to_binary(income - outcome) <>
              "<br>" <>
              "R&D: " <>
              :nitro.to_binary(rnd) <>
              "%<br>" <>
              "options: " <>
              :nitro.to_binary(opt) <>
              "%<br>" <>
              "reserved: " <>
              :nitro.to_binary(rsv) <>
              "%<br>" <>
              "credited: " <> :nitro.to_binary(ins) <> "%<br>"
        ),
        NITRO.panel(
          class: :column20,
          body:
            :string.join(
              :lists.map(
                fn ERP."Person"(cn: cn, hours: h) ->
                  cn ++ '&nbsp;(' ++ :erlang.integer_to_list(h) ++ ')'
                end,
                :kvs.all('/plm/' ++ id ++ '/staff')
              ),
              ','
            )
        ),
        NITRO.panel(
          class: :column30,
          body:
            NITRO.panel(
              class: :chart,
              body: "<canvas heigh=100 id=\"" <> :nitro.to_binary(name) <> "\"></canvas>"
            )
        ),
        NITRO.panel(
          class: :column6,
          body: NITRO.link(class: [:sgreen, :button], postback: {:invest, id}, body: "Invest")
        )
      ]
    )
  end
end
