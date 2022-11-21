defmodule BPE.Rows.Trace do
  require N2O
  require FORM
  require NITRO
  require BPE
  require Logger

  def doc(),
    do:
      "This is the actor trace row (step) representation. " <>
        "Used to draw trace of the processes"

  def id(), do: BPE.hist(task: {:task, :Init})

  def new(name, h, _) do
    task =
      case BPE.hist(h, :task) do
        [] -> BPE.hist(id(), :task)
        x -> x
      end

    docs = BPE.hist(h, :docs)

    NITRO.panel(
      id: :form.atom([:tr, :nitro.to_list(name)]),
      class: :td,
      body: [
        NITRO.panel(
          class: :column6,
          body: :io_lib.format("~s", [:nitro.to_list(:erlang.element(2, task))])
        ),
        NITRO.panel(
          class: :column20,
          body:
            :string.join(
              :lists.map(
                fn x -> :nitro.to_list([:erlang.element(1, x)]) end,
                docs
              ),
              ', '
            )
        )
      ]
    )
  end
end
