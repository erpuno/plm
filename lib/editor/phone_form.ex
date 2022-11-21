defmodule BPE.Pass do
  require FORM
  require ERP

  def doc(), do: "Форма одноразового OTP паролю для 2FA"

  def id(), do: ERP."Employee"()

  def new(name,_,_) do

    FORM.document(name: :form.atom([:otp,name]),

        sections: [ FORM.sec(name: ["Аутентифікуйтесь: "] ) ],

        buttons:  [ FORM.but(id: :decline, name: :decline,
                             title: "Відміна", class: [:cancel],
                             postback: {:"Close",[]} ),

                    FORM.but(id: :proceed, name: :proceed,
                             title: "Далі", class: [:button,:sgreen],
                             sources: [:number_phone_none,:code_phone_none],
                             postback: {:"Next",:form.atom([:otp,:otp,name])})],

        fields:   [ FORM.field(id: :number, name: :number, type: :string,
                               title: "Логін:",  labelClass: :label),

                    FORM.field(id: :code, name: :code, type: :password,
                               title: "Пароль:",  labelClass: :label ) ] )
   end
end
