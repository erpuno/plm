defmodule BPE.Index do
  require Logger
  require N2O
  require NITRO
  require FORM
  require BPE
  require KVS

  def index_header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column6, body: "No"),
        NITRO.panel(class: :column10, body: "Name"),
        NITRO.panel(class: :column6, body: "Module"),
        NITRO.panel(class: :column20, body: "State"),
        NITRO.panel(class: :column20, body: "Documents"),
        NITRO.panel(class: :column20, body: "Manage")
      ]
    )
  end

  def event(:init) do
    :nitro.clear(:tableRow)
    :nitro.clear(:tableHead)
    :nitro.insert_top(:tableHead, index_header())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)
    mod = BPE.Forms.Create
    :nitro.insert_bottom(:frms, :form.new(mod.new(mod, mod.id(), []), mod.id(), []))

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :creator,
        body: "New Process",
        postback: :create,
        class: [:button, :sgreen]
      )
    )

    :nitro.hide(:frms)

    for BPE.process(id: i) <-
          Enum.filter(
            :kvs.feed('/bpe/proc'),
            fn BPE.process(name: n) -> n == :n2o.user() end
          ) do
      :nitro.insert_bottom(:tableRow, BPE.Rows.Process.new(:form.atom([:row, i]), :bpe.load(i), []))
    end
  end

  def event({:complete, id}) do
    p = :bpe.load(id)
    :bpe.start(p, [])
    :bpe.next(id)

    :nitro.update(
      :form.atom([:tr, :row, id]),
      BPE.Rows.Process.new(:form.atom([:row, id]), :bpe.proc(id), [])
    )
  end

  def event({:spawn, _}) do
    atom = :process_type_pi_none |> :nitro.q() |> :nitro.to_atom

    id =
      case :bpe.start(atom.def(), []) do
        {:error, i} -> i
        {:ok, i} -> i
      end

    :nitro.insert_after(
      :header,
      BPE.Rows.Process.new(:form.atom([:row, id]), :bpe.proc(id), [])
    )

    :nitro.hide(:frms)
    :nitro.show(:ctrl)
  end

  def event({:discard, []}), do: [:nitro.hide(:frms), :nitro.show(:ctrl)]
  def event(:create), do: [:nitro.hide(:ctrl), :nitro.show(:frms)]
  def event(_), do: []
end
