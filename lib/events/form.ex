defmodule FORM.Index do
  require N2O
  require NITRO
  require FORM
  require Logger

  def event({:client, {:form, mod}}) do
    :nitro.insert_bottom(:stand, NITRO.h3(body: :nitro.to_binary(mod)))

    :nitro.insert_bottom(
      :stand,
      NITRO.p(body: mod.doc())
    )

    :nitro.insert_bottom(
      :stand,
      NITRO.panel(:form.new(mod.new(mod, mod.id(), []), mod.id(), []), class: :form)
    )
  end

  def event(:init) do
    :nitro.clear(:stand)

    for f <- :application.get_env(:form, :registry, []) do
      send(self(), {:client, {:form, f}})
    end
  end

  def event({ev, name}) do
    :nitro.wire(
      :lists.concat([
        'console.log(\"',
        :io_lib.format('~p', [{ev, name}]),
        '\");'
      ])
    )
  end

  def event(_), do: []
end
