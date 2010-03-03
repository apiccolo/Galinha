class Admin::PedidosController < Admin::AdminController
  PER_PAGE = 50

  in_place_edit_for :pedido, :entrega_endereco
  in_place_edit_for :pedido, :entrega_numero
  in_place_edit_for :pedido, :entrega_complemento
  in_place_edit_for :pedido, :entrega_bairro
  in_place_edit_for :pedido, :entrega_cep
  in_place_edit_for :pedido, :entrega_cidade
  in_place_edit_for :pedido, :nota_fiscal

  # Bem vindo à lista de pedidos.
  def index
    define_filtros(params)
    @todos   = Pedido.count(:all)
    @demais  = Pedido.contador_por_status
    @pedidos = Pedido.paginate(:all, 
                               :conditions => @filtros, 
                               :order => @order, 
                               :page => params[:page], 
                               :per_page => @per_page,
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
  verify :params => [:id, :do],
         :only => :alterar_status
  def alterar_status
    pedido = Pedido.find(params[:id])
    if pedido
      case params["do"]
        when "iniciar"
          pedido.iniciar!
        when "pagamento_confirmado"
          pedido.pagamento_confirmado!
        when "envelopar"
          pedido.envelopar!
        when "imprimir_nota_fiscal"
          pedido.imprimir_nota_fiscal!
        when "enviar_correio"
          pedido.enviar_correio!
        when "incluir_cod_postagem"
          pedido.incluir_cod_postagem!
        when "receber"
          pedido.cliente_recebeu!
        when "finalizar"
          pedido.encerrar!
        when "cancelar"
          pedido.cancelar!
      end
    else
      flash[:error] = "Pedido inexistente"
    end
    redirect_to :action => :index
  end
  
  # DELETE /produtos/1
  # DELETE /produtos/1.xml
  def destroy
    @pedido = Pedido.find(params[:id])
    @pedido.destroy
    respond_to do |format|
      format.html { redirect_to(admin_pedidos_path) }
      format.xml  { head :ok }
    end
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
  
  verify :params => [ :id ],
         :only => [ :envelopado ]
  # Marca o pedido como envelopado
  def envelopado
    pedido = Pedido.find(params[:id])
    if pedido and pedido.processando_envio?
      pedido.envelopar!
      render :update do |page|
        page << "alert('Pedido #{pedido.id} marcado como envelopado!')"
      end
      #render :partial => "window_close"
    else
      render :update do |page|
        page << "alert('ERRO ao marcar pedido como envelopado!')"
      end
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
  
  # Dado um pedido (via ID) e 
  # pedido[nota_fiscal], grava-lo.
  verify :params => [:id, :pedido],
         :only => :gravar_nota_fiscal
  def gravar_nota_fiscal
    pedido = Pedido.find(params[:id])
    if pedido and pedido.processando_envio_envelopado?
      pedido.update_attributes(:nota_fiscal => params[:pedido][:nota_fiscal])
      pedido.imprimir_nota_fiscal!
      render :update do |page|
        page.alert("Nota fiscal do pedido #{pedido.id} impressa!\nPedido salvo com sucesso!")
        page.visual_effect("fade", "input_dados")
      end      
    else
      render :update do |page|
        page.alert("ERRO: pedido inexistente ou nota fiscal já informada!")
      end
    end
  end
  
  # Dado um array de IDs de pedidos,
  # Marcar todos como enviados!
  verify :params => [:ids],
         :only => :marca_enviados_em_lote
  def marca_enviados_em_lote
    pedidos = Pedido.find(params[:ids])
    pedidos.each{ |p| p.enviar_correio! if p.processando_envio_notafiscal? }
    render :partial => "window_close"
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
  
  # Dado um pedido (via ID) e 
  # pedido[cod_postagem], grava-lo e 
  # informa-lo ao cliente.
  verify :params => [:id, :pedido],
         :only => :gravar_cod_postagem
  def gravar_cod_postagem
    pedido = Pedido.find(params[:id])
    if pedido and pedido.produto_enviado?
      pedido.update_attributes(:codigo_postagem => params[:pedido][:cod_postagem])
      if params[:pedido][:suprimir_email]
        pedido.status = 'produto_enviado_cod_postagem'
        pedido.save
        complemento = "- email não enviado."
      else
        pedido.incluir_cod_postagem!
        complemento = "e informações enviadas ao cliente."
      end
      render :update do |page|
        page.alert("Pedido #{pedido.id} ok #{complemento}")
        page.visual_effect("fade", "table_row_#{pedido.id}")
      end      
    else
      render :update do |page|
        page.alert("ERRO: pedido inexistente ou codigo já informado!")
      end
    end
  end
  
  # Inclui o pedido no array Setting['pedidos_selecionados']
  def nf_marcar
    pedido_id = params[:id].to_i
    if not @settings['pedidos_selecionados']
      Settings.defaults['pedidos_selecionados'] = [ 'empty' ]
      @settings['pedidos_selecionados'] = Settings['pedidos_selecionados']
    end
    if @settings['pedidos_selecionados'].include?(pedido_id)
      # Acho que precisa sempre da atribuicao para salvar...
      Settings['pedidos_selecionados'] = Settings['pedidos_selecionados'].delete_if { |x| (x == pedido_id) }
      message = "<span>NF desmarcada!</span>"
    else
      # Acho que precisa sempre da atribuicao para salvar...
      Settings['pedidos_selecionados'] = Settings['pedidos_selecionados'] + [ pedido_id ]
      message = "<span>NF marcada!</span>"
    end
    render :update do |page|
      page.replace "heart_#{pedido_id}", :text => message
    end
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
                                                        my_status, @pedido.id])
      end
    end
  end
  
  def define_filtros(p)
    @filtros = {}
    @filtros.merge!(:status => p["status"]) if p["status"] and not p["status"].blank? and (p["status"] != 'todos')
    @filtros.merge!("pedidos.id" => p["id"]) if p["id"] and not p["id"].blank?
    @filtros.merge!(:nota_fiscal => p["nota_fiscal"]) if p["nota_fiscal"] and not p["nota_fiscal"].blank?
    @filtros.merge!(:entrega_cep => p["entrega_cep"]) if p["entrega_cep"] and not p["entrega_cep"].blank?
    @filtros.merge!("pessoas.email" => p["pessoas_email"]) if p["pessoas_email"] and not p["pessoas_email"].blank?
    
    #@filtros.merge!(p["search_field"] => p["search_value"]) if p["search_field"] and p["search_value"] and not p["search_value"].blank?
    @per_page = (p[:per_page] and not p[:per_page].blank?) ? p[:per_page].to_i : PER_PAGE
    @order    = (p[:order] and not p[:order.blank?]) ? p[:order] : "pedidos.id DESC"
  end  
end