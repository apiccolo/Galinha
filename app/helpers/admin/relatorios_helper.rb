module Admin::RelatoriosHelper

  def cores_por_regiao(estado)
    cores = ""
    if %w(AM AC AP PA RO RR TO).include?(estado) #norte
      cores = "98DB11"  
    elsif %w(AL BA CE MA PB PE PI RN SE).include?(estado) #nordeste
      cores = "FF9900" 
    elsif %w(GO MS MT DF).include?(estado) #centro-oeste
      cores = "FFD42A" 
    elsif %w(SP RJ MG ES).include?(estado) #sudeste
      cores = "5599FF" 
    elsif %w(RS SC PR).include?(estado) #sul
      cores = "F09BBE" 
    end
    return cores
  end
  
  def data_para_grafico(strdata)
    y, m, d = strdata.split("-")
    return Date.new(y.to_i, m.to_i, d.to_i).strftime("%d/%b/%Y")
  end
  
end