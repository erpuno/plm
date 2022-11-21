defmodule FIN.Index do
  require N2O
  require NITRO
  require FORM
  require BPE
  require KVS
  require ERP
  require Logger

  def accountsHeader() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column33, body: "Account"),
        NITRO.panel(class: :column10, body: "Type"),
        NITRO.panel(class: :column2, body: "Ballance")
      ]
    )
  end

  def txsHeader() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column66, body: "Account"),
        NITRO.panel(class: :column10, body: "Amount"),
        NITRO.panel(class: :column10, body: "Datetime")
      ]
    )
  end

  def pushAccounts(cn) do

     account = ERP."Acc"(id: cn ++ '/local')

     :nitro.insert_bottom(
        :accountsRow,
        FIN.Rows.Account.new(:form.atom([:row, :account, cn]), account, [])
      )

     cn
  end

  def pushTxs(cn) do

    for i <- :kvs.feed('/fin/tx/' ++ cn ++ '/local') do
      :nitro.insert_bottom(
        :txsRow,
        FIN.Rows.Transaction.new(:form.atom([:row, :transaction, cn]), i, [])
      )
    end

    cn
  end

  def event(:init) do
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)
    :nitro.clear(:accountsHead)
    :nitro.clear(:accountsRow)
    :nitro.clear(:txsHead)
    :nitro.clear(:txsRow)

    case :n2o.user() do
      [] ->
        :nitro.hide(:head)

        PLM.box(
          PLM.Forms.Error,
          {:error, 1, "Not authenticated", "User must be authenticated in order to view account and transactions"}
        )

      ERP."Employee"(person: ERP."Person"(cn: id)) ->
        send self(), {:direct, {:txs, id} }
    end
  end

  def event({:txs, id}) do
    :nitro.insert_top(:accountsHead, FIN.Index.accountsHeader())
    :nitro.insert_top(:txsHead, FIN.Index.txsHeader())
    :nitro.update(:num, NITRO.span(body: KVS.Index.parse(:n2o.user())))
    :nitro.hide(:frms)
    id |> pushAccounts |> pushTxs
  end

  def event({:off, _}), do: :nitro.redirect("ldap.htm")
  def event(_), do: []
end
