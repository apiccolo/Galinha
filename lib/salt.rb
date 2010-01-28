class Salt
  #=========================================#
  # Funções exclusivas para Mudança de Base #
  #=========================================#

  # Método da classe (que usa o método do OBJ abaixo)
  def self.converteParaBase50(num)
    s = Salt.new
    return s.emBase50(num)
  end

  # Método da classe (que usa o método do OBJ abaixo)
  def self.converteParaBase10(str)
    s = Salt.new
    return s.emBase10(str)
  end

  # Transforma um dado número "d" (de base 10) em uma string na base 50
  def emBase50(d,base=50)
    tmp = Salt.new
    fim = Array.new
    i = 0
    r = d.divmod(base)
    fim[i] = tmp.paraLetras(r[1].to_i)
    while (r[0] > 0)
      i += 1
      r = r[0].divmod(base)
      fim[i] = tmp.paraLetras(r[1].to_i)
    end
    return fim.reverse!.to_s
  end

  # Transforma uma dada string "w" em número na base 10
  def emBase10(w,base=50)
    tmp = Salt.new
    i = 0
    fim = 0
    while (i <= (w.size-1))
      fim += tmp.paraDigitos(w[i].chr) * (base ** (w.size-i-1))
      i += 1
    end
    return fim
  end

  # Devolve a letra correspondente entre 0..49
  def paraLetras(d)
    #excluídos o "L minúsculo" e o "ó maiúsculo"
    a = Array.new; a.push('x','y','z','a','b','c','u','v','w','d','e','f','r','s','t','g','h','i','o','p','q','j','k','m','n')
    b = Array.new; b.push('Z','A','Y','B','X','C','W','D','V','E','U','F','T','G','S','H','R','I','Q','J','P','K','N','L','M')
    c = a + b
    return c[d]
  end

  # Devolve o número corresponde, dado a letra
  def paraDigitos(s)
    a = Array.new; a.push('x','y','z','a','b','c','u','v','w','d','e','f','r','s','t','g','h','i','o','p','q','j','k','m','n')
    b = Array.new; b.push('Z','A','Y','B','X','C','W','D','V','E','U','F','T','G','S','H','R','I','Q','J','P','K','N','L','M')
    c = a + b
    return c.index(s)
  end
end #class
