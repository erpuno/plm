defmodule PLM.Forms.Error do
  require N2O
  require NITRO
  require FORM
  require Logger
  require Record

  def doc(), do: "Error Form."
  def id(), do: {:error, [], "General Error", []}

  def new(name, {:error, no, msg, body}, _) do
    NITRO.panel(
      class: :form,
      body: [
        NITRO.h4(body: "ERROR: " <> msg),
        NITRO.p(style: "margin: 20;", body: body),
        NITRO.panel(
          class: :buttons,
          body: NITRO.link(class: [:button, :sgreen], body: "Got it", id: name, postback: {:off, no})
        )
      ]
    )
  end
end
