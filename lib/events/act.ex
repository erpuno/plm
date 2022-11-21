defmodule BPE.Actor do
  require N2O
  require NITRO
  require FORM
  require BPE
  require Logger

  def header() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column6, body: "State"),
        NITRO.panel(class: :column6, body: "Documents")
      ]
    )
  end

  def ok(id) do
    :nitro.insert_top(:tableHead, BPE.Actor.header())

    for i <- :bpe.hist(id) do
      :nitro.insert_bottom(
        :tableRow,
        BPE.Rows.Trace.new(:nitro.atom([:trace, :nitro.to_list(BPE.hist(i, :id))]), i, [])
      )
    end
  end

  def event(:init) do
    id = :p |> :nitro.qc() |> :nitro.to_list()
    :nitro.update(:num, id)
    :nitro.update(:n, id)

    case :n2o.user() do
      [] ->
        PLM.box(
          PLM.Forms.Error,
          {:error, 1, "Not authenticated",
           "User must be authenticated in order to view the process trace.<br>" <>
             "You can do that at <a href=\"ldap.htm\">LDAP</a> page."}
        )

      _ ->
        event({:txs, id})
    end
  end

  def event({:txs, id}) do
    :nitro.clear(:tableHead)
    :nitro.clear(:tableRow)

    case :kvs.get('/bpe/proc', id) do
      {:error, _} -> PLM.box(PLM.Forms.Error, {:error, 2, "No process found.", []})
      {:ok, BPE.process(id: id)} -> ok(id)
    end
  end

  def event({:off, _}), do: :nitro.redirect("bpe.htm")
  def event(_), do: []
end
