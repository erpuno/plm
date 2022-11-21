defmodule PLM do
  require N2O
  require FORM

  def box(mod, r) do
    :nitro.clear(:stand)

    rec =
      case r do
        [] -> mod.id
        x -> x
      end

    :nitro.insert_bottom(:stand, :form.new(mod.new(mod, rec, []), rec, []))
  end
end

defmodule PLM.Application do
  use Application

  def start(_, _) do
    :cowboy.start_clear(:http, [{:port, :application.get_env(:n2o, :port, 8043)}],
                                       %{env: %{dispatch: :n2o_cowboy.points()}})
    Supervisor.start_link([], strategy: :one_for_one, name: PLM.Supervisor)
  end
end
