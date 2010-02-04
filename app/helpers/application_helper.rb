# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  def flash_message
    if !flash.empty?
      mensagens = []
      [ :notice, :info, :warning, :error ].each{ |type| mensagens << content_tag(:p, flash[type], :class => type) if flash[type] }
      content_tag(:div, mensagens, :id => "flash_message")
    end
  end

  def flash_message_mais_fechar
    if !flash.empty?
      mensagens = []
      [ :notice, :info, :warning, :error ].each{ |type| mensagens << content_tag(:p, flash[type], :class => type) if flash[type] }
      link_para_fechar = [ content_tag(:p, link_to_function("Fechar [x]", "$('flash_message_wrapper').hide()"), :id => "fechar", :class => "margin0") ]
      
      aux = content_tag(:div, mensagens + link_para_fechar, :id => "flash_message")
      content_tag(:div, aux, :id => "flash_message_wrapper")
    end
  end
  
  def number2currency(number)
    number_to_currency(number, :precision => 2, 
                               :unit => "R$", 
                               :separator => ",",
                               :delimiter => ".",
                               :format => "<span class=\"real\">%u</span> %n")
  end
  
  # Retorna TRUE se o valor guardado nas settings é "1"
  def settings_checked?(var)
    return (var == "1")
  end
  
end
