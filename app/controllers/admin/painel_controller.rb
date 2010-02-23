class Admin::PainelController < Admin::AdminController

  # Bem vindo à administração.
  def index
    @hoje = Date.today
    @como_conheceu = Pessoa.contador('como_conheceu', :de => 10.days.ago, :ate => @hoje)
    @pedidos_e_pagos = Pedido.pedidos_e_pagamentos(:de => @hoje, :ate => @hoje)
  end
end