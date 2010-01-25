require 'digest/sha1'
class ComprarController < ApplicationController
  layout "default"
  
  #------------------------------------------------------------
  #   Mostra o carrinho de compras
  #
  def index
    @carrinho = session[:carrinho]
    recolhe_outros_produtos(@carrinho)    

    @pedido = Pedido.new(params[:pedido])
    @pessoa = Pessoa.new(params[:pessoa])
  end
  
  #------------------------------------------------------------
  #   Formulário de confirmacao do pedido
  #
  verify :method => :post,
         :only => :confirma_pedido
  def confirma_pedido
    @carrinho = session[:carrinho]
    recolhe_outros_produtos(@carrinho)
    
    @pedido = Pedido.new(params[:pedido])
    @pessoa = Pessoa.new(params[:pessoa])
    @pedido.pessoa = @pessoa if (@pedido and @pessoa)
    if @carrinho
      @carrinho.each do |c|
        @pedido.produtos_quantidades.build(:produto_id => c.produto_id,
                                           :preco_unitario => c.preco_unitario,
                                           :qtd => c.qtd,
                                           :presente => c.presente)
      end
    end
    # Se validou tudo certinho...
    if @pedido.valid?
      #render :text => "pedido ok"
      # Guarda o pedido na session e pede que o cliente confirme.
      # Ao passar por aqui validado, guarda na session...
      session[:pedido] = @pedido
    else
      render :action => "index"
    end
  end

  #------------------------------------------------------------  
  #    Grava dados do pedido e redireciona para pgmto...
  # 
  verify :session => :pedido,
         :only => :gravar
  def gravar
    @pedido = session[:pedido]
    if @pedido.save
      session[:pedido] = nil
      redirect_to :action => "go2pgmto", :id => @pedido.id, :md5 => encrypt(@pedido.id)
    else
      flash[:error] = "Erro ao gravar pedido"
      redirect_to :action => "index"
    end
  end


  #------------------------------------------------------------  
  #    Mostra botao do UOLPagSeguro...
  # 
  def go2pgmto
    @pedido = Pedido.find(params[:id], :include => [:pessoa, :produtos_quantidades])
    if encrypt(@pedido.id) != params[:md5]
      render :text => "error..."
    else
      @pedido.iniciar! if @pedido.pedido?
    end
  end

  #==================================================================#
  #                             PRODUTOS                             #
  #==================================================================#  
  
  #------------------------------------------------------------
  #   Mostra os produtos disponíveis
  #
  def produtos
    @produtos = Produto.disponivel.paginate(:page => params[:page], :per_page => 20)
  end
  
  #------------------------------------------------------------
  #   Mostra ficha do produto 
  #   ATENÇÃO: nao usa o layout, mostra produto em MODALBOX
  #
  def produto
    @produto = Produto.find(params[:id])
    render :layout => false, :template => "comprar/produto"
  end
  
  #==================================================================#
  #                      CARRINHO DE COMPRAS                         #
  #==================================================================#
  
  #-----------------------------------------------------------
  #   Acrescenta o produto no carrinho
  #
  verify :params => [:produto_id],
         :method => :post,
         :only => :incluir
  def incluir
    incluir_produto(params[:produto_id].to_i)
    if request.xhr?
      @carrinho = session[:carrinho]
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
      @carrinho = session[:carrinho]
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end
  
  #-----------------------------------------------------------
  #   Esvazia o carrinho
  #
  def esvaziar
    session[:carrinho].clear if session[:carrinho]
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
      @carrinho = session[:carrinho]
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
    if request.xhr?
      @carrinho = session[:carrinho]
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
      @carrinho = session[:carrinho]
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
      @carrinho = session[:carrinho]
      refresh_carrinho_e_outros
    else
      redirect_to :action => :index
    end
  end

  #-----------------------------------------------------------
  #   Altera valor e label de acordo com o estado escolhido
  #
  verify :params => [:estado],
         :only => :atualiza_frete_por_estado
  def atualiza_frete_por_estado
    valor = @settings["frete_por_estado"][params[:estado]].to_f
    #@pedido.frete = valor
    render :update do |page|
      page << "$('pedido_frete').value=#{valor};"
      page.replace_html :frete_por_estado, :text => number_to_currency(valor)
      page.replace_html :estado_label, :text => params[:estado]
    end
  end

  #-----------------------------------------
  #   PRIVATE METHODS
  #
  protected
  
  #-----------------------------------------
  #   Atualiza o div do carrinho, das 
  #   sugestoes e dos "leve_tambem"
  #
  def refresh_carrinho_e_outros
    recolhe_outros_produtos(session[:carrinho])
    render :update do |page|
      page.replace_html 'meu_carrinho', :partial => 'mostra_carrinho'
      page.replace_html 'leve_tambem',  :partial => 'mostra_leve_tambem'
      page.replace_html 'sugestoes',    :partial => 'mostra_sugestoes'
    end
  end
  
  #-----------------------------------------
  #   PRIVATE METHODS
  #
  private
    
  def recolhe_outros_produtos(carrinho)
    @leve_tambem = ProdutoCombo.leve_tambem(@carrinho)
    @sugestoes = Produto.sugere_demais_produtos(@carrinho)
  end
  
  #-----------------------------------------
  #   Retira o produto do carrinho
  #
  def retirar_produto(produto_id)
    if session[:carrinho] and session[:carrinho].kind_of?(Array)
      session[:carrinho].delete_if { |c| c.produto_id == produto_id }
    end
  end
  
  #-----------------------------------------
  #   Inclui o produto no carrinho
  #
  def incluir_produto(produto_id)
    produto = Produto.find(produto_id)
    produto_no_carrinho = ProdutosQuantidade.new(:produto_id => produto.id,
                                                 :preco_unitario => produto.preco,
                                                 :qtd => 1,
                                                 :presente => false)
    tem_no_carrinho = false
    if session[:carrinho]
      if session[:carrinho].kind_of?(Array) and not session[:carrinho].empty?
        # Procura pra saber se tem no carrinho
        # se tiver, acrescenta +1 na qtd.
        session[:carrinho].each do |c|
          if (c.produto_id == produto_id)
            c.update_attributes(:qtd => (c.qtd + 1))
            tem_no_carrinho = true
          end
        end
      end
    else
      session[:carrinho] = Array.new unless session[:carrinho]
    end
    session[:carrinho] << produto_no_carrinho unless tem_no_carrinho
  end
  
  def embrulhar_produto(produto_id)
    if session[:carrinho] and session[:carrinho].kind_of?(Array) and not session[:carrinho].empty?
      session[:carrinho].each do |c|
        c.update_attributes(:presente => !c.presente) if (c.produto_id == produto_id)
      end
    end
  end
  
  def alterar_qtd_produto(produto_id, qtd)
    if session[:carrinho] and session[:carrinho].kind_of?(Array) and not session[:carrinho].empty?
      session[:carrinho].each do |c|
        if (qtd == 0)
          retirar_produto(produto_id)
        else
          c.update_attributes(:qtd => qtd) if (c.produto_id == produto_id)
        end
      end
    end
  end
  
  def trocar_por_produto_combo(produto_id)
    produto = ProdutoCombo.find(produto_id)
    session[:carrinho].clear if session[:carrinho] and session[:carrinho].kind_of?(Array)
    produto_no_carrinho = ProdutosQuantidade.new(:produto_id => produto.id,
                                                 :preco_unitario => produto.preco,
                                                 :qtd => 1,
                                                 :presente => false)
    session[:carrinho] << produto_no_carrinho
  end
  
  def desmembrar_combo_em_produtos(combo_id, produto_id)
    retirar_produto(combo_id)
    combo = ProdutoCombo.find(combo_id)
    combo.produto_ids.each do |item_id|
      incluir_produto(item_id) if (item_id != produto_id)
    end
  end
  
  protected
  
  def encrypt(str)
    salt = str.to_s.reverse
    Digest::SHA1.hexdigest(str.to_s + salt.to_s)
  end
  
end
