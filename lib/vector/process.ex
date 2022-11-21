defmodule BPE.Rows.Process do
  require NITRO
  require N2O
  require FORM
  require BPE
  require ERP
  require Logger
  require Record

  def doc(),
    do:
      "This is the actor table row representation in FORM CSS. Used to draw active processes" <>
        " in <a href=\"bpe.htm\">BPE process table</a> but displayed as class=form."

  def id(), do: BPE.process()

  def new(name, proc, _) do
    pid = BPE.process(proc, :id)

    NITRO.panel(
      id: :form.atom([:tr, name]),
      class: :td,
      body: [
        NITRO.panel(
          class: :column6,
          body:
            NITRO.link(
              href: "act.htm?p=" <> :nitro.to_binary(pid),
              body: :nitro.to_binary(pid)
            )
        ),
        NITRO.panel(
          class: :column6,
          body:
            case BPE.process(proc, :name) do
              [] -> []
              ERP."Employee"(person: ERP."Person"(cn: cn)) -> cn
              name -> :nitro.to_binary name
            end
        ),
        NITRO.panel(
          class: :column6,
          body: :nitro.to_list(BPE.process(proc, :module))
        ),
        NITRO.panel(
          class: :column20,
          body:
            case :bpe.head(pid) do
              [] -> []
              x = BPE.sequenceFlow() -> BPE.sequenceFlow(BPE.hist(x, :task), :target)
              x -> :nitro.compact(x)
            end
        ),
        NITRO.panel(
          class: :column20,
          body: :nitro.to_list(BPE.process(proc, :module))
        ),
        NITRO.panel(
          class: :column10,
          body:
            case BPE.process(proc, :current) do
              :Final ->
                []

              _ ->
                [
                  NITRO.link(
                    postback: {:complete, BPE.process(proc, :id)},
                    class: [:button, :sgreen],
                    body: "Go",
                    source: [],
                    validate: []
                  )
                ]
            end
        )
      ]
    )
  end
end
