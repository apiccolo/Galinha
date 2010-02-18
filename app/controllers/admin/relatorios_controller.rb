class Admin::RelatoriosController < Admin::AdminController

  # Bem vindo à administração.
  def index
    @pedidos_por_estado = Pedido.count(:group => 'entrega_estado')
    @total = 0 
    @pedidos_por_estado.each { |k,v| @total += v }
    
    #ultimos_dias = 90.days.ago    
    #@produtos_vendidos = Produto.vendidos(:pagos_depois_de => ultimos_dias)
    @como_conheceu = Pessoa.contador('como_conheceu')
    
    @pedidos_e_pagos = Pedido.pedidos_e_pagamentos
  end
end