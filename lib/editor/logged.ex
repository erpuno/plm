defmodule LDAP.Forms.Access do
  require N2O
  require NITRO
  require FORM
  require Logger
  require Record

  def doc(), do: "Access."
  def id(), do: {:access, :n2o.user() |> KVS.Index.parse(), "to all services."}

  def new(name, {:access, _user, msg}, _) do
    FORM.document(
      name: :form.atom([:otp, name]),
      sections: [FORM.sec(name: "GRANTED: " <> msg)],
      buttons: [
        FORM.but(
          id: :ok,
          name: :ok,
          title: "Revoke",
          class: [:button, :sgreen],
          postback: {:revoke, name}
        )
      ],
      fields: [
        FORM.field(
          id: :cn,
          name: :cn,
          type: :string,
          disabled: true,
          title: "Logged in as:",
          fieldClass: :column3
        )
      ]
    )
  end
end
