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
  end
  
  # Mostra form com opcoes:
  # 1. file_upload
  # 2. text_area
  def entrar_arquivo
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
  
  # Mostra as opcoes de
  # relatorios disponiveis.
  def relatorios
  end
  
  # Processa o relatorio
  def processar_relatorio
    inicio = DateTime.civil(params[:relatorio]["inicio(1i)"].to_i, params[:relatorio]["inicio(2i)"].to_i, params[:relatorio]["inicio(3i)"].to_i, params[:relatorio]["inicio(4i)"].to_i, params[:relatorio]["inicio(5i)"].to_i, 0, 0)
    final  = DateTime.civil(params[:relatorio]["final(1i)"].to_i, params[:relatorio]["final(2i)"].to_i, params[:relatorio]["final(3i)"].to_i, params[:relatorio]["final(4i)"].to_i, params[:relatorio]["final(5i)"].to_i, 0, 0)
    if params[:selecao]=="intervalo"
      #model = Pedido.posteriores_a(inicio).anteriores_a(final)
      conditions = ["pedidos.data_pedido IS NOT NULL AND
                     (status = 'produto_enviado_cod_postagem' OR status = 'recebido_pelo_cliente' OR status = 'encerrado') AND
                     pedidos.data_pedido >= ? AND
                     pedidos.data_pedido <= ? ", inicio, final ]
    elsif params[:selecao]=="numero_notas"
      #model = Pedido.nf_inicial(params[:numero_nf][:inicio]).nf_final(params[:numero_nf][:final])
      inicio = params[:numero_nf][:inicio]
      final  = params[:numero_nf][:final]
      conditions = ["pedidos.data_pedido IS NOT NULL AND
                     (status = 'produto_enviado_cod_postagem' OR status = 'recebido_pelo_cliente' OR status = 'encerrado') AND
                     pedidos.nota_fiscal * 1 >= ? AND
                     pedidos.nota_fiscal * 1 <= ? ", inicio, final ]
    elsif params[:selecao]=="my_where"
      conditions = ["#{params[:condicoes]}"]
    end
    
    @pedidos = Pedido.find(:all, 
                           :conditions => conditions,
                           :order => "nota_fiscal ASC",
                           :include => :pessoa )
    if (params[:opcao]=="tela")
      render :update do |page|
        page[:spinner].hide
        page.replace_html "resultado", 
               :partial => "relatorio_tela",
               :locals => { 
                 :pedidos => @pedidos,
                 :inicio => inicio,
                 :final => final
                }        
      end
    elsif (params[:opcao]=="arquivo")
      timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
      arquivo1 = "#{RAILS_ROOT}/public/tmp/relatorio-folhamatic-#{timestamp}.txt" #fml"
      linhas1  = gera_relatorio("admin/automacoes/relatorio_folhamatic", arquivo1)

      arquivo2 = "#{RAILS_ROOT}/public/tmp/compradores-sp-#{timestamp}.txt" #fml"
      linhas2  = gera_relatorio("admin/automacoes/relatorio_compradores_sp", arquivo2)

      render :update do |page|
        page[:spinner].hide
        page.replace_html "resultado", 
                :partial => "relatorio_tela_link2arquivo",
                :locals => { 
                  :timestamp => timestamp,
                  :arquivo => [arquivo1, arquivo2],
                  :totais => [linhas1, linhas2]
                }
      end
    end
  end
  
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