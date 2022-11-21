defmodule PLM.Rows.Payment do
  require N2O
  require FORM
  require NITRO
  require BPE
  require Record
  require ERP
  require Logger

  def doc(),
    do:
      "This is the actor trace row (step) representation. " <>
        "Used to draw trace of the processes"

  def id(), do: ERP."Payment"(volume: {:money, 0, 1})

  def new(name, ERP."Payment"(invoice: id, price: p, volume: v, from: tic, type: cur), _) do
    {:money, s, m} = :dec.mul(p, v)

    x =
      case cur do
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
          body: id
        ),
        NITRO.panel(
          class: :column10,
          body: :erlang.float_to_list(m * :math.pow(10, -s), [{:decimals, x}])
        ),
        NITRO.panel(
          class: :column10,
          body: tic
        )
      ]
    )
  end
end
