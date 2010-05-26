class Admin::RelatoriosController < Admin::AdminController

  before_filter :intervalo, :only => :index

  # Bem vindo à administração.
  def index
    @pedidos_e_pagos = Pedido.pedidos_e_pagamentos(:de => @data1, :ate => @data2)
    @pedidos_por_estado = Pedido.count(:conditions => ["created_at >= ? and created_at <= ? ", @data1, @data2], 
                                       :group => 'entrega_estado')
    @produtos_vendidos = Produto.vendidos(:de => @data1, :ate => @data2)
    @como_conheceu = Pessoa.contador('como_conheceu', :de => @data1, :ate => @data2)
  end
  
  private
  
  def intervalo    
    if params["de"] and params["ate"]
      @data1 = Date.new(params["de"]["year"].to_i, params["de"]["month"].to_i, params["de"]["day"].to_i) #|| 30.days.ago
      @data2 = Date.new(params["ate"]["year"].to_i, params["ate"]["month"].to_i, params["ate"]["day"].to_i)
    else
      @data1 = 10.days.ago # default = 10 dias atras...
      @data1 = Date.new(Date.today.year, Date.today.month, 1) if (Date.today.day > 10) # se (hoje > dia 10), pega desde o inicio do mes
      @data2 = Date.today
    end
  end
  
end