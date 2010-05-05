class VideosController < ApplicationController
  layout "default"
  
  before_filter :dados_produto_1, :except => [:pelucia, :cd_caixinha_musica]
  
  def index
    redirect_to :action => "trailer"
  end
  
  def trailer
    render :template => "videos/filme"
  end
  
  def galinha_pintadinha
    render :template => "videos/filme"
  end
  
  def pintinho_amarelinho
    render :template => "videos/filme"
  end
  
  def baratinha
    render :template => "videos/filme"
  end
  
  def karaoke
    render :template => "videos/filme"
  end
  
  def pelucia
    render :template => "videos/pelucia"
  end

  def cd_caixinha_musica
    render :template => "videos/cd_caixinha_musica"
  end
  
  private
  
  def dados_produto_1
    @produto = Produto.find(1)
  end
end
