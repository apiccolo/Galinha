module Admin::ProdutosHelper
  
  def preco_column(record)
    number_to_currency(record.preco, :precision => 2, 
                                     :unit => 'R$ ', 
                                     :separator => ",", 
                                     :format => "%u %n")
  end
end