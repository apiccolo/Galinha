class Admin::PedidosController < Admin::AdminController
  PER_PAGE = 10

  # Bem vindo à lista de pedidos.
  def index
    busca = {}
    @pedidos = Pedido.paginate(:all, 
                               :conditions => busca, 
                               :order => "id DESC", 
                               :page => params[:page], 
                               :per_page => PER_PAGE,
                               :include => [:pessoa, :produtos_quantidades])
  end
  
  # Mostra detalhes/ficha do pedido
  verify :params => :id,
         :only => :detalhes
  def detalhes
    @pedido = Pedido.find(params[:id])
    render :partial => "detalhes",
           :locals => { :pedido => @pedido }
  end
  
  # Altera o status do pedido
  verify :params => :id,
         :only => :alterar_status
  def alterar_status
  end
  
  # Mostra pagina de impressao dos envelopes de pedidos.
  before_filter :busca_pedido_para_impressao, 
                :only => :print
  def print
    if @pedido
      # nota fiscal ou envelope??
      if params[:nota_fiscal] and (params[:nota_fiscal].to_i==1)
        render :partial => "print_notafiscal",
               :locals => { :pedido => @pedido,
                            :proximo => @proximo }
      else
        render :partial => "print",
               :locals => { :pedido => @pedido,
                            :proximo => @proximo }
      end
    else
      render :text => "ERRO: nao ha pedido para impressao."
    end
  end
  
  # Lista CEPs dos pedidos com status ='processando_envio'
  # para controle de postagem (que virá do correio).
  def lista_ceps
    status  = "processando_envio_notafiscal"
    pedidos = Pedido.find(:all, :conditions => ["status = ?", status], 
                          :order => "pedidos.entrega_cep ASC, pedidos.id ASC", 
                          :include => :pessoa)
    render :partial => "lista_ceps", 
           :locals => { 
             :status => status,
             :pedidos => pedidos,
             :cod_postagem_text_field => false
           }
  end
  
  # Informar codigos de postagem
  # aos respectivos compradores
  def controle_postagem
    status  = "produto_enviado"
    pedidos = Pedido.find(:all, :conditions => ["status = ?", status], 
                          :order => "pedidos.entrega_cep ASC, pedidos.id ASC", 
                          :include => :pessoa)
    render :partial => "lista_ceps", 
           :locals => {
             :status => status,
             :pedidos => pedidos,
             :cod_postagem_text_field => true
            }
  end
  
  private
  
  def busca_pedido_para_impressao
    #encontra o pedido
    my_status  = "processando_envio"
    my_status += "_envelopado" if (params[:nota_fiscal] and (params[:nota_fiscal].to_i==1))

    #encontra o pedido
    @pedido = params[:id] ? 
             Pedido.find(params[:id]) : 
             Pedido.find(:first, :conditions => ["status = ?", my_status])
    
    if @pedido
      @proximo = nil
      ha_proximo = (Pedido.count(:conditions => ["status = ?", my_status]) > 1)
      if ha_proximo
        @proximo = Pedido.find(:first, :conditions => ["status = ? AND id <> ?", 
                                                        my_status, pedido.id])
      end
    end
  end
  
end