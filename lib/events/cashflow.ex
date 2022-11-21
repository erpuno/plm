defmodule PLM.CashFlow do
  require N2O
  require NITRO
  require FORM
  require BPE
  require ERP
  require Logger

  def investmentsHeader() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column33, body: "Investment"),
        NITRO.panel(class: :column10, body: "Paid"),
        NITRO.panel(class: :column2, body: "Name")
      ]
    )
  end

  def incomeHeader() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column66, body: "Monthly Invoice"),
        NITRO.panel(class: :column10, body: "Amount"),
        NITRO.panel(class: :column10, body: "From")
      ]
    )
  end

  def outcomeHeader() do
    NITRO.panel(
      id: :header,
      class: :th,
      body: [
        NITRO.panel(class: :column66, body: "Subaccount"),
        NITRO.panel(class: :column10, body: "Amount"),
        NITRO.panel(class: :column10, body: "From")
      ]
    )
  end

  def pushInvestments(code) do
    for i <- :kvs.feed('/plm/' ++ code ++ '/staff') do
      cn = ERP."Person"(i, :cn)

      sum =
        :lists.foldl(
          fn ERP."Payment"(volume: v, price: p), {_, acc} ->
            {x, y} = :dec.mul(v, p)
            {x, acc + y}
          end,
          {0, 0},
          :kvs.feed('/fin/tx/' ++ cn ++ '/local')
        )

      :nitro.insert_bottom(
        :investmentsRow,
        PLM.Rows.Investment.new(
          :form.atom([:row, :investment, code]),
          ERP."Payment"(price: {0, 1}, volume: sum, from: cn),
          []
        )
      )
    end

    code
  end

  def pushIncome(code) do
    for i <- :kvs.feed('/plm/' ++ code ++ '/income') do
      :nitro.insert_bottom(
        :incomeRow,
        PLM.Rows.Payment.new(:form.atom([:row, :income, code]), i, [])
      )
    end

    code
  end

  def pushOutcome(code) do
    for i <- :kvs.feed('/plm/' ++ code ++ '/outcome') do
      :nitro.insert_bottom(
        :outcomeRow,
        PLM.Rows.Payment.new(:form.atom([:row, :outcome, code]), i, [])
      )
    end

    code
  end

  def event(:init) do
    :nitro.clear(:investmentsHead)
    :nitro.clear(:investmentsRow)
    :nitro.clear(:incomeHead)
    :nitro.clear(:incomeRow)
    :nitro.clear(:outcomeHead)
    :nitro.clear(:outcomeRow)
    :nitro.insert_top(:investmentsHead, PLM.CashFlow.investmentsHeader())
    :nitro.insert_top(:outcomeHead, PLM.CashFlow.outcomeHeader())
    :nitro.insert_top(:incomeHead, PLM.CashFlow.incomeHeader())
    :nitro.clear(:frms)
    :nitro.clear(:ctrl)

    mod = BPE.Forms.Create
    :nitro.insert_bottom(:frms, :form.new(mod.new(mod, mod.id(), []), mod.id(), []))

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :create_investment,
        body: "New Investment",
        postback: :create_investment,
        class: [:button, :sgreen]
      )
    )

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :create_income,
        body: "New Income",
        postback: :create_income,
        class: [:button, :sgreen]
      )
    )

    :nitro.insert_bottom(
      :ctrl,
      NITRO.link(
        id: :create_outcome,
        body: "New Outcome",
        postback: :create_outcome,
        class: [:button, :sgreen]
      )
    )

    :nitro.hide(:frms)

    code = :p |> :nitro.qc() |> :nitro.to_list() |> pushInvestments |> pushIncome |> pushOutcome

    case :kvs.get(:writer, '/plm/' ++ code ++ '/income') do
      {:error, _} ->
        PLM.box(PLM.Forms.Error, {:error, 1, "No product found.", []})

      _ ->
        :nitro.update(:n, code)
        :nitro.update(:num, code)
    end
  end

  def event(:create_investment), do: [:nitro.hide(:ctrl), :nitro.show(:frms)]
  def event(:create_income), do: [:nitro.hide(:ctrl), :nitro.show(:frms)]
  def event(:create_outcome), do: [:nitro.hide(:ctrl), :nitro.show(:frms)]
  def event({:discard, []}), do: [:nitro.hide(:frms), :nitro.show(:ctrl)]

  def event(_), do: []
end
