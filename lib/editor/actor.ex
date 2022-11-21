defmodule BPE.Forms.Create do
  require N2O
  require NITRO
  require FORM
  require KVS
  require Logger

  def doc(), do: "Dialog for creation of BPE processes."
  def id(), do: {:pi, []}

  def new(name, {:pi, _code}, _) do
    :erlang.put(:process_type_pi_none, "bpe_account")
    FORM.document(
      name: :form.atom([:pi, name]),
      sections: [FORM.sec(name: "New process: ")],
      buttons: [
        FORM.but(
          id: :form.atom([:pi, :decline]),
          title: "Discard",
          class: :cancel,
          postback: {:discard, []}
        ),
        FORM.but(
          id: :form.atom([:pi, :proceed]),
          title: "Create",
          class: [:button, :sgreen],
          sources: [:process_type],
          postback: {:spawn, []}
        )
      ],
      fields: [
        FORM.field(
          name: :process_type,
          id: :process_type,
          type: :select,
          title: "Type",
          tooltips: [],
          options: [
            FORM.opt(name: "bpe_account", title: "Client Acquire [QUANTERALL]"),
            FORM.opt(name: "bpe_account", title: "Client Tracking [QUANTERALL]"),
            FORM.opt(
              name: "bpe_account",
              checked: true,
              title: "Client Account [SYNRC BANK]"
            )
          ]
        )
      ]
    )
  end
end
