defmodule PLM.Rows.Product do
  require N2O
  require FORM
  require NITRO
  require ERP
  require Logger
  require Record

  def doc(),
    do: "PLM product."

  def id(), do: ERP."Product"(code: 'NYNJA')
  def mul({a, b}, {c, d}), do: {a + c, b * d}

  def sum(feed) do
    {_, b} =
      :lists.foldl(
        fn ERP."Payment"(volume: v, price: p), {x, y} ->
          {_, y1} = mul(v, p)
          {x, y + y1}
        end,
        {0, 0},
        :kvs.all(feed)
      )

    b
  end

  def new(name, prod, _) do
    code = ERP."Product"(prod, :code)
    income = ('/plm/' ++ code ++ '/income') |> sum
    outcome = ('/plm/' ++ code ++ '/outcome') |> sum
    feed = '/fin/acc/' ++ code
    {:ok, ERP."Acc"(rate: {_, rnd})} = :kvs.get(feed, code ++ '/R&D')
    {:ok, ERP."Acc"(rate: {_, ins})} = :kvs.get(feed, code ++ '/insurance')
    {:ok, ERP."Acc"(rate: {_, opt})} = :kvs.get(feed, code ++ '/options')
    {:ok, ERP."Acc"(rate: {_, rsv})} = :kvs.get(feed, code ++ '/reserved')

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(
          class: :column6,
          body: NITRO.link(href: 'cashflow.htm?p=' ++ code, body: code)
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
                fn ERP."Person"(cn: id, hours: h) ->
                  id ++ '&nbsp;(' ++ :erlang.integer_to_list(h) ++ ')'
                end,
                :kvs.all('/plm/' ++ code ++ '/staff')
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
          body: NITRO.link(class: [:sgreen, :button], postback: {:invest, code}, body: "Invest")
        )
      ]
    )
  end
end
