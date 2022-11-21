defmodule LDAP.Index do
  require FORM
  require ERP

  def findByPhone(phone, list) do
      :lists.foldl(fn x, acc ->
         case ERP."Employee"(x, :phone) == phone do
              true -> [x|acc]
              false -> acc
         end
      end, [], list)
  end

  def event(:init) do
      :nitro.clear(:stand)
      mod = BPE.Pass
      form = mod.new(mod, mod.id(), [])
      html = :form.new(form, mod.id(), [])
      :nitro.insert_bottom(:stand, html)
  end

  def event({:"Next",_}) do
      phone = :nitro.q(:number_phone_none)
      clients = :kvs.all '/plm/employees'
      res = findByPhone(phone, clients)
      case res do
          [x] -> case :nitro.to_binary(ERP."Employee"(x, :type)) do
                        "admin" -> :nitro.redirect("backoffice/domains.htm")
                        "consumer" -> :nitro.redirect("consumer/service.htm")
                 end
          _ -> :nitro.redirect("index.html")
      end
  end
  def event({:"Close",_}), do: :nitro.redirect("index.html")
  def event(_), do: :ok

end

