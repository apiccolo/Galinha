class VideosController < ApplicationController
  layout "default"
  
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
  
end
