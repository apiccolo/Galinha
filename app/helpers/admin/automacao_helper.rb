module Admin::AutomacaoHelper
    
  # retorna uma string com N
  # espacos em branco.
  def brancos(n)
    complete(" ", n.to_i)
  end
  
  # retorna uma string 
  # com N zeros!
  def zeros(n)
    complete("0", n.to_i)
  end
    
  private
  
  # Preenche uma string com N
  # posicoes com o dado char.
  def complete(char, n)
    return (char * n)
  end
  
end