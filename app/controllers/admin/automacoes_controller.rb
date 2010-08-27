class Admin::AutomacoesController < Admin::AdminController
  helper "admin/folhamatic/empresa", 
         "admin/folhamatic/produtos", 
         "admin/folhamatic/notas_fiscais", 
         "admin/folhamatic/impostos_das_notas",
         "admin/folhamatic/chave_lancamento_produtos",
         "admin/folhamatic/lancamento_produtos",
         "admin/folhamatic/clientes"

  # Bem vindo à administração.
  def index
    @envelopes = Pedido.count(:conditions => ["status = 'processando_envio'"])
    @notasfisc = Pedido.count(:conditions => ["status = 'processando_envio_envelopado'"])
    @para_corr = Pedido.count(:conditions => ["status = 'processando_envio_notafiscal'"])
    @cpostagem = Pedido.count(:conditions => ["status = 'produto_enviado'"])
  end
  
  # Mostra form com opcoes:
  # 1. file_upload
  # 2. text_area
  def entrar_arquivo
  end
  
  def nota_fiscal_avulsa
    @pedido = nil
    @pedido = Pedido.find(params[:id]) if params[:id]
    render :template => false
  end
  
  # Recebe dados (arquivo ou text_area)
  # e apresenta-os na tabela para conferir
  # com os pedidos.
  def processar_dados
    if params[:opcao] == 'arquivo'
      @file_content = params[:arquivo].read
    elsif params[:opcao] == 'text-area'
      @file_content = params[:file_content]
    else
      redirect_to :action => "entrar_arquivo"
    end
  end

  # Dado o ID de um pedido,
  # marca-lo como processando envio
  verify :params => [ :id ],
         :only => [ :confirmar_pagamento ]
  def confirmar_pagamento
    pedido = Pedido.find( params[:id] )
    if pedido and pedido.aguardando_pagamento?
      pedido.pagamento_confirmado!
      render :update do |page|
        page.alert("Pagamento confirmado do pedido #{pedido.id}: processar envio!")
        page.replace("link2_pedido_#{pedido.id}", :text => "ok!")
      end
    else
      render :nothing => true
    end
  end
  
  def desmarcar_todos
    Settings['pedidos_selecionados'] = [ 'empty' ]
    redirect_to :action => "relatorios"
  end
  
  # Mostra as opcoes de relatorios disponiveis.
  def relatorios
  end
  
  def arquivo_folhamatic
    #render :text => params.inspect
    conditions = []
    conditions = ["pedidos.id IN (?)", params['pedidos_ids']] if (params['selecao']=="automatica")
    conditions = ["pedidos.id IN (#{params[:condicoes]})"] if (params['selecao']=="my_where")
    @pedidos = Pedido.find(:all, :conditions => conditions,
                           :order => "nota_fiscal ASC",
                           :include => :pessoa )
    if (params[:opcao]=="tela")
      render :template => "admin/automacoes/_relatorio_tela",
             :locals => { :pedidos => @pedidos }
    elsif (params[:opcao]=="arquivo")
      timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
      arquivo1 = "#{RAILS_ROOT}/public/tmp/relatorio-folhamatic-#{timestamp}.txt"
      linhas1  = gera_relatorio("admin/automacoes/relatorio_folhamatic", arquivo1)

      render :relatorios
      send_file arquivo1, :type => 'application/octet-stream'
    end
  end
  
  private
    
  # Dado um partial e o local do arquivo de saida
  # gera o relatorio descrito no partial;
  # Retorna o num linhas do arquivo final.
  def gera_relatorio(partial, arquivo)
    linhas = 0
    tmp = render_to_string :template => false, 
                           :partial => partial
    f = File.new(arquivo, "w")
    f.write(tmp)
    f.close
    wc = %x[wc #{arquivo}] #word count!
    linhas = wc.split[0]
    return linhas
  end
  
  def entrega_arquivo
    send_file params[:arquivo] #, :type => 'application/octet-stream' #'text/xml; charset=utf-8'
  end
end