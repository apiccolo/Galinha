class ComprarController < ApplicationController
  layout "default"
  
  # Mostra o carrinho de compras
  def index
    @carrinho = session[:carrinho]
    @produtos = Produto.all
  end
  
  # Acrescenta o produto no carrinho
  verify :params => [:produto_id],
         :only => :incluir
  def incluir
    incluir_produto(params[:produto_id].to_i)
    redirect_to :action => :index
  end

  # Retira o produto do carrinho
  verify :params => [:produto_id],
         :only => :retirar  
  def retirar
    retirar_produto(params[:produto_id].to_i)
    redirect_to :action => :index
  end
  
  verify :params => [:produto_id],
         :only => :embrulhar
  def embrulhar
    embrulhar_produto(params[:produto_id].to_i)
    redirect_to :action => :index
  end
  
  private
  
  # Retira o produto do carrinho
  def retirar_produto(produto_id)
    if session[:carrinho] and session[:carrinho].kind_of?(Array)
      session[:carrinho].delete_if { |c| c.produto_id == produto_id }
    end
  end
  
  # Inclui o produto no carrinho
  def incluir_produto(produto_id)
    produto = ProdutoQuantidade.new(:produto_id => produto_id,
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
    session[:carrinho] << produto unless tem_no_carrinho
  end
  
  def embrulhar_produto(produto_id)
    if session[:carrinho] and session[:carrinho].kind_of?(Array) and not session[:carrinho].empty?
      session[:carrinho].each do |c|
        c.update_attributes(:presente => !c.presente) if (c.produto_id == produto_id)
      end
    end
  end
  
end
