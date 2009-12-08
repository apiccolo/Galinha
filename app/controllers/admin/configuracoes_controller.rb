class Admin::ConfiguracoesController < Admin::AdminController

  # Bem vindo à administração.
  def index
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
    f = File.new(fullpath2file, "w+")
    f.write(params[:content])
    f.close
    flash[:notice] = "Arquivo editado e salvo com sucesso"
    redirect_to :action => "index"    
  end
  
end