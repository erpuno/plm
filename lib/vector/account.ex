defmodule FIN.Rows.Account do
  require N2O
  require FORM
  require NITRO
  require BPE
  require ERP
  require Record
  require Logger

  def doc(),
    do:
      "This is the transaction representation. " <>
        "Used to draw the account transactions"

  def id(), do: ERP."Acc"(id: 'Anon/local', ballance: {:money, 0, 1})

  def new(name, ERP."Acc"(id: acc, ballance: p, rate: v, type: type), _) do
    [_,t] = :string.tokens(acc, '/')
    {:money, s, m} = :dec.mul(p, v)

    x =
      case type do
        :crypto -> s
        :fiat -> 2
        _ -> 2
      end

    NITRO.panel(
      id: :form.atom([:tr, :nitro.to_list(name)]),
      class: :td,
      body: [
        NITRO.panel(
          class: :column66,
          body: t
        ),
        NITRO.panel(
          class: :column10,
          body: type
        ),
        NITRO.panel(
          class: :column10,
          body: :erlang.float_to_list(m * :math.pow(10, -s), [{:decimals, x}])
        )
      ]
    )
  end
end
