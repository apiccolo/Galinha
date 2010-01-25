class Admin::ConfiguracoesController < Admin::AdminController

  # Bem vindo à administração.
  def index
    @settings = Settings.all
  end
  
  def salvar
    salva_configuracoes(params[:settings])
    flash[:notice] = "Configurações salvas"
    redirect_to :action => "index"
  end
  
  # Abre arquivo para ser editado em modo texto
  verify :params => [:file, :nome_arquivo, :rows, :cols],
         :only => [:editar_arquivo]
  def editar_arquivo
    fullpath2file = "#{RAILS_ROOT}/#{params[:file]}"
    if File.exists?(fullpath2file)
      @f = File.open(fullpath2file)
    else
      flash[:error] = "Arquivo inexistente"
      redirect_to :action => "index"
    end
  end
  
  # Salva conteudo do arquivo editado
  verify :params => [:file, :content],
         :only => [:salvar_arquivo]
  def salvar_arquivo
    fullpath2file = "#{RAILS_ROOT}/#{params[:file]}"
    if File.exists?(fullpath2file)
      f = File.new(fullpath2file, "w+")
      f.write(params[:content])
      f.close
      flash[:notice] = "Arquivo editado e salvo com sucesso"
    else
      flash[:notice] = "Arquivo inexistente"
    end
    redirect_to :action => "index"    
  end
  
  # Guarda valor do checkbox via AJAX
  verify :params => [:settings],
         :only => [:update_check_box]
  def update_check_box
    salva_configuracoes(params[:settings])
    render :nothing => true
  end
  
  # opera a variavel "frete_por_estado", na qual
  # um Hash { :estado => valor, :estado => valor... }
  # é armazenado para caulculo do frete
  def frete_por_estado
  end
  
  # Salva os valores [ estado + frete ]
  def frete_por_estado_salvar
    #render :text => params.inspect
    Settings.frete_por_estado = fretes_por_estado_to_hash( params[:settings][:frete_por_estado] )
    flash[:notice] = "Fretes salvos"
    redirect_to :action => "frete_por_estado"
  end
  
  # Adiciona uma linha de [ estado + frete ]
  def frete_por_estado_incluir_row
    render :update do |page|
      page.insert_html :bottom, "estados_e_fretes", 
                       :partial => "frete_estado_row", 
                       :locals => { 
                         :estado => "", 
                         :frete => "" 
                       }
    end
  end

  private
  
  def fretes_por_estado_to_hash(my_array)
    fe = {}
    my_array.each do |h|
      #logger.debug("----> #{h['estado']}, #{h['frete']} ")
      fe.merge!( h['estado'] => h['frete'] )
    end
    return fe
  end
  
  def salva_configuracoes(settings)
    settings.each do |key, value|
      #render :text => "#{key} ... #{value}"
      Settings["#{key}"] = value
    end
  end
  
end