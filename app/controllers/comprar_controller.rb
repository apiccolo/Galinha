require 'digest/sha1'
class ComprarController < ApplicationController
  layout "default"
  
  #------------------------------------------------------------
  #   Mostra o pedido [= carrinho de compras + dados cliente]
  #
  def index
    inicia_pedido(params)
    recolhe_outros_produtos
  end
  
  #------------------------------------------------------------
  #   Formulário de confirmacao do pedido
  #
  verify :method => :post, 
         :session => :pedido,
         :only => [ :confirmar_pedido, :gravar ]
  def confirmar_pedido
    retorna_pedido_da_session
    atualiza_pedido(params)
    if not (@pessoa.valid? and @pedido.valid?)
      recolhe_outros_produtos
      render "index"
    end
  end
  
  def gravar
    retorna_pedido_da_session
    if not (@pessoa.valid? and @pedido.valid?)
      recolhe_outros_produtos
      render "index"
    elsif @pedido.save! # Se validou tudo certinho...
      @pedido.iniciar!
      session[:pedido] = nil
      redirect_to :action => "go2pgmto", :id => @pedido.id, :md5 => encrypt(@pedido.id)
    else
      flash[:error] = "Erro ao salvar pedido"
      redirect_to :action => :index
    end
  end

  #------------------------------------------------------------  
  #    Mostra botao do UOLPagSeguro...
  # 
  def go2pgmto
    @pedido = Pedido.find(params[:id], :include => [:pessoa, :produtos_quantidades])
    if @pedido
      if (encrypt(@pedido.id) != params[:md5])
        flash[:error] = "Inválido"
        redirect_to :action => :index
      end
    else
      flash[:error] = "Pedido não encontrado"
      redirect_to :action => :index
    end
  end
  
  #==================================================================#
  #                  CLIENTE REVÊ SEU PEDIDO                         #
  #==================================================================#  
  
  #------------------------------------------------------------   
  #     Mostra ao cliente dados do pedido
  #
  def seu_pedido
    @pedido = Pedido.find(params[:pid])
    begin
      if not @pedido.check(params[:pid], params[:pbase], params[:chkpid], params[:md5])
        flash[:error] = "Dados do pedido incorretos"
        redirect_to :action => "index"
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Pedido inexistente"
      redirect_to :action => "index"
    end
  end
  
  #------------------------------------------------------------   
  #     Cliente preenche pesquisa de satisfacao
  #  
  def feedback
    @pedido = Pedido.find(params[:pid])
    begin
      if not @pedido.check(params[:pid], params[:pbase], params[:chkpid], params[:md5])
        flash[:error] = "Dados do pedido incorretos"
        redirect_to :action => "index"
      elsif request.post?
        @pedido.update_attributes(params[:pedido])
        @pedido.notifica_ao_admin_feedback

        flash[:info] = "Agradecemos o envio de sua opinião."
        redirect_to root_url
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Pedido inexistente"
      redirect_to :action => "index"
    end
  end
  
  #------------------------------------------------------------   
  #     Cliente marca que recebeu produto
  #  
  def recebi
    @pedido = Pedido.find(params[:pid])
    begin
      if @pedido.check(params[:pid], params[:pbase], params[:chkpid], params[:md5])
        @pedido.cliente_recebeu!
        render :text => "<b>Obrigado!</b>"
      else
        render :nothing => true
      end
    rescue ActiveRecord::RecordNotFound
      render :nothing => true
    end
  end

  #------------------------------------------------------------
  #        Recebe POST do UOLPagSeguro
  #
  skip_before_filter :verify_authenticity_token,
                     :only => :confirmacao_uol
  def confirmacao_uol
    #ultimo token = 2681E14119A141D3947DFB3EDBB727AA
    @confirmou = false
    msg = "Retorno automático do UOLPagSeguro"
    if params['Referencia'] and not params['Referencia'].empty?
      begin
        @pedido = Pedido.find(params['Referencia'].to_i)
        @pedido.update_attribute('forma_pgmto', params["TipoPagamento"])

        my_params = ajusta_paramsUOL(params)
        @pedido.retornos_pgmtos.create(my_params)
        msg = "Pedido #{@pedido.id}: retorno recebido do UOLPagSeguro"

        if @pedido.aguardando_pagamento? and 
           ((params['StatusTransacao']=='Aprovado') or (params['StatusTransacao']=='Completo'))
          @pedido.pagamento_confirmado!
          @confirmou = true
          Mailer.deliver_admin_pgmto_confirmado(@pedido) #NOTIFICAR!
          msg = "Pagamento do pedido #{@pedido.id} confirmado! Processando envio..."
        end        
      rescue ActiveRecord::RecordNotFound
        msg = 'ERRO: Pedido Nao Encontrado'
      end
    end
    
    #msg += "<!-- #{params.inspect} -->"
    #Mailer.deliver_admin_post_recebido_UOLPagSeguro(params)
    respond_to do |format|
      format.html  { } #render :text => msg }
      format.xml   { render :xml => params.to_xml }
    end
  end
  
#  def tmp
#    h = Net::HTTP.new(ARGV[0] || 'https://pagseguro.uol.com.br/pagseguro-ws/checkout/NPI.jhtml', 80)
#    url = ARGV[1] || '/'
#    begin
#      resp, data = h.get(url, nil) { |a| }
#    rescue Net::ProtoRetriableError => detail
#      head = detail.data
#    end
#    render :text => "#{data.inspect}"
#  end

  #==================================================================#
  #                             PRODUTOS                             #
  #==================================================================#  
  
  #------------------------------------------------------------
  #   Mostra os produtos disponíveis
  #
  #def produtos
  #  @produtos = Produto.disponivel.paginate(:page => params[:page], :per_page => 20)
  #end
  
  #------------------------------------------------------------
  #   Mostra ficha do produto 
  #   ATENÇÃO: nao usa o layout, mostra produto em MODALBOX
  #
  def produto
    @produto = Produto.find(params[:id])
    render :layout => false, :template => "comprar/produto"
  end
  
  #------------------------------------------------------------
  #   Mostra a imagem grande de um dado thumbnail
  #   ATENÇÃO: nao usa o layout, retorna apenas a tag IMG
  #  
  def imagem
    thumb = params[:thumb]
    render :text => "<img src=\""+ thumb.gsub('_thumb', '') +"\" alt=\"produto grande\">"
  end
  
  #==================================================================#
  #                       CUPOM DE DESCONTO                          #
  #==================================================================#
  
  #------------------------------------------------------------
  #   Formulário de confirmacao do pedido
  #
  verify :params => :cupom_desconto,
         :only => :validar_cupom_desconto
  def validar_cupom_desconto
    render :nothing => true
    #render :update do |page|
    #  page.replace_html 'desconto', :text => "<td>ok!</td>"
    #end
  end
  
  #==================================================================#
  #                      CARRINHO DE COMPRAS                         #
  #==================================================================#
  before_filter :inicia_pedido, :only => [ :incluir, :retirar, :esvaziar, 
                                           :embrulhar, :alterar_qtd, 
                                           :trocar_por_combo, :desfazer_combo, 
                                           :atualizar_frete_por_estado ]
  
  #-----------------------------------------------------------
  #   Acrescenta o produto no carrinho
  #
  verify :params => [:produto_id],
         :method => :post,
         :only => :incluir
  def incluir
    incluir_produto(params[:produto_id].to_i)
    if request.xhr?
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end

  #-----------------------------------------------------------
  #   Retira o produto do carrinho
  # 
  verify :params => [:produto_id],
         :method => :post,
         :only => :retirar  
  def retirar
    retirar_produto(params[:produto_id].to_i)
    if request.xhr?
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end
  
  #-----------------------------------------------------------
  #   Esvazia o carrinho (i.e. tira pedido da Session!)
  #
  def esvaziar
    esvazia_carrinho if session[:pedido]
    redirect_to :action => :index
  end

  #---------------------------------
  #   Limpa o pedido da sessao
  #  
  def renovar_pedido
    session[:pedido] = nil if session[:pedido]
    redirect_to :action => :index
  end
  
  #-----------------------------------------------------------
  #   Marca PARA PRESENTE em produto do carrinho
  #
  verify :params => [:produto_id],
         :method => :post,
         :only => :embrulhar
  def embrulhar
    embrulhar_produto(params[:produto_id].to_i)
    if request.xhr?
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end
  
  #-----------------------------------------------------------
  #   Altera quantidade em produto do carrinho
  #
  verify :params => [:produto_id, :qtd],
         :only => :alterar_qtd
  def alterar_qtd
    alterar_qtd_produto(params[:produto_id].to_i, params[:qtd].to_i)
    recalcula_frete
    if request.xhr?
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end
  
  #-----------------------------------------------------------
  #   Troca produtos do carrinho por um único combo
  #
  verify :params => [:produto_id],
         :method => :post,
         :only => :trocar_por_combo
  def trocar_por_combo
    trocar_por_produto_combo(params[:produto_id].to_i)
    if request.xhr?
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end

  #-----------------------------------------------------------
  #   Retira produto do combo (i.e. desfaz o combo)
  #
  verify :params => [:combo_id, :produto_id],
         :method => :post,
         :only => :desfazer_combo
  def desfazer_combo
    desmembrar_combo_em_produtos(params[:combo_id].to_i, params[:produto_id].to_i)
    if request.xhr?
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end

  #-----------------------------------------------------------
  #   Altera valor e label de acordo com o estado escolhido
  #
  verify :params => [:estado],
         :only => :atualizar_frete_por_estado
  def atualizar_frete_por_estado
    if not params[:estado].blank?
      frete = calculo_do_frete_por_estado(params[:estado])
      atualiza_pedido(:frete => frete,
                      :frete_tipo => "FRETE GALINHA - #{params[:estado]}",
                      :entrega_estado => params[:estado])
      refresh_carrinho_e_outros #(:except => ['leve_tambem', 'sugestoes'])
    else
      render :nothing => true
    end
  end

  #-----------------------------------------
  #   PROTECTED METHODS
  #
  protected
  
  def recalcula_frete
    if not @pedido.entrega_estado.blank?
      if (@settings['frete_tipo'] == 'estadual')
        frete = calculo_do_frete_por_estado(@pedido.entrega_estado)
        atualiza_pedido(:frete => frete)
      elsif (@settings['frete_tipo'] == 'correios')
        # TODO...
      end
    end
  end
  
  #-----------------------------------------
  #   Atualiza o div do carrinho, das 
  #   sugestoes e dos "leve_tambem"
  #
  def refresh_carrinho_e_outros(my_options = {})
    options = { :except => [], 
                :only => [] }.merge!(my_options)
    recolhe_outros_produtos
    render :update do |page|
      page.replace 'meu_carrinho', :partial => 'mostra_carrinho' unless options[:except].include?("meu_carrinho")
      page.replace 'frete_desconto_total', :partial => 'frete_desconto_total' unless options[:except].include?("frete_desconto_total")
      page.replace 'leve_tambem',  :partial => 'mostra_leve_tambem' unless options[:except].include?("leve_tambem")
      page.replace 'sugestoes',    :partial => 'mostra_sugestoes' unless options[:except].include?("sugestoes")
    end
  end
    
  #-----------------------------------------
  #   PRIVATE METHODS
  #
  private
  
  def inicia_pedido(params={})
    retorna_pedido_da_session
    if not @pedido
      @pedido = Pedido.new(params[:pedido])
      guarda_pedido_na_session
      
      @pessoa = @pedido.build_pessoa(params[:pessoa])
      @carrinho = @pedido.produtos_quantidades
    end
  end

  def retorna_pedido_da_session
    if session[:pedido]       
      @pedido = session[:pedido]
      @pessoa = @pedido.pessoa
      @carrinho = @pedido.produtos_quantidades
      #limpa_erros if request.get?
    end
  end
  
  def guarda_pedido_na_session
    session[:pedido] = @pedido
  end
  
  def atualiza_pedido(params)
    @pedido.update_attributes(params[:pedido])
    @pedido.pessoa.update_attributes(params[:pessoa])
  end
  
  def limpa_erros
    @pedido.errors.clear
    @pessoa.errors.clear
  end
  
  def recolhe_outros_produtos
    @leve_tambem = ProdutoCombo.leve_tambem(@pedido.produtos_quantidades)
    @sugestoes = Produto.sugere_demais_produtos(@pedido.produtos_quantidades, @settings['loja_mostrar_sugestoes_empty_default'])
  end
  
  #------------------------------------
  #   Retira o produto do carrinho
  #
  def retirar_produto(produto_id)
    if @pedido.produtos_quantidades and not @pedido.produtos_quantidades.empty?
      @pedido.produtos_quantidades.delete_if { |c| c.produto_id == produto_id }
    end
  end
  
  #------------------------------------
  #   Inclui o produto no carrinho
  #
  def incluir_produto(produto_id)
    produto = Produto.find(produto_id)
    tem_no_carrinho = false
    if @pedido.produtos_quantidades and not @pedido.produtos_quantidades.empty?
      # Procura pra saber se tem no carrinho: se tiver, acrescenta +1 na qtd.
      @pedido.produtos_quantidades.each do |c|
        if (c.produto_id == produto_id)
          c.update_attributes(:qtd => (c.qtd + 1))
          tem_no_carrinho = true
        end
      end
    end
    @pedido.produtos_quantidades.build(:produto_id => produto.id,
                                       :preco_unitario => produto.preco,
                                       :qtd => 1,
                                       :presente => false) unless tem_no_carrinho
  end

  #-----------------------------------------------------
  #   Embrulha/Desembrulha (p/ presente) o produto
  #  
  def embrulhar_produto(produto_id)
    if @pedido.produtos_quantidades and not @pedido.produtos_quantidades.empty?
      p = Produto.find(produto_id)
      @pedido.produtos_quantidades.each do |c|
        if (c.produto_id == produto_id)
          preco_now = (c.presente) ? p.preco : (p.preco + p.plus_presente)
          c.update_attributes(:presente => !c.presente,
                              :preco_unitario => preco_now)
        end
      end
    end
  end

  #-------------------------------------------
  #   Altera a qtd do produto no carrinho
  #  
  def alterar_qtd_produto(produto_id, qtd)
    if @pedido.produtos_quantidades and not @pedido.produtos_quantidades.empty?
      @pedido.produtos_quantidades.each do |c|
        if (qtd == 0)
          retirar_produto(produto_id)
        else
          c.update_attributes(:qtd => qtd) if (c.produto_id == produto_id)
        end
      end
    end
  end
  
  #--------------------------------------------------------
  #   Remove produtos do carrinho e inclui ProdutoCombo
  #
  def trocar_por_produto_combo(produto_id)
    produto = ProdutoCombo.find(produto_id)
    if produto and @pedido.produtos_quantidades and not @pedido.produtos_quantidades.empty?
      esvazia_carrinho #@pedido.produtos_quantidades.each { |c| retirar_produto(c.produto_id) }
      incluir_produto(produto.id)
    end
  end
  
  
  #----------------------------------------------------------------
  #   Retira combo do carrinho e inclui "demais" ProdutosSimples 
  #
  def desmembrar_combo_em_produtos(combo_id, produto_id)
    retirar_produto(combo_id)
    combo = ProdutoCombo.find(combo_id)
    combo.produto_ids.each do |item_id|
      incluir_produto(item_id) if (item_id != produto_id)
    end
  end
  
  #------------------------------------------------------------
  #   Dado um estado, retorna valor do frete do(s) produtos
  #
  def calculo_do_frete_por_estado(estado)
    valor_frete = @settings["frete_por_estado"][estado].to_f
    n = @pedido.n_itens
    if (n <= 0)
      return 0
    elsif (n < @settings['frete_estadual_qtd_limite'].to_i)
      return valor_frete
    else
      acrescimo = @settings['frete_estadual_multiplicador']
      #logger.debug("N ======> #{n} itens: EVAL ======> "+ eval(acrescimo).to_f.to_s)
      return (valor_frete + eval(acrescimo))
    end
  end
  
  def esvazia_carrinho
    @pedido.produtos_quantidades.clear
  end
  
  def atualiza_pedido(p = {})
    if (p and not p.empty?)
      if (p[:pessoa] and p[:pedido])
        @pedido.update_attributes(p[:pedido])
        @pessoa.update_attributes(p[:pessoa])
      else
        @pedido.update_attributes(p)
      end
    end
  end
  
  # Dados os params vindos do UOLPagSeguro,
  # ajusta-los para guardar em RETORNO_PGMTOS.
  def ajusta_paramsUOL(p)
    my_p = {
      'demais' => ''
    }
    p.each do |key, value|
      my_key = key.to_s.downcase
      if ((my_key == 'transacaoid') or
          (my_key == 'tipopagamento') or
          (my_key == 'tipofrete') or
          (my_key == 'numitens'))
        my_p[key.to_s.downcase] = value
        my_p[key.to_s.downcase] = value.to_i if (my_key=='numitens')
      elsif (my_key == 'statustransacao')
        my_p['status'] = value
      else
        #concatena um texto com os demais params
        my_p['demais'] += "[#{key}] = #{value}; " 
      end
    end
    return my_p    
  end
  
  protected
  
  def encrypt(str)
    salt = str.to_s.reverse
    Digest::SHA1.hexdigest(str.to_s + salt.to_s)
  end
  
end
