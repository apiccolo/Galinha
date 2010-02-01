module Admin::PessoasHelper
  
  def sexo_column(record)
    if record.sexo=='f'
      image_tag("/images/icons/female.png")
    elsif record.sexo=='m'
      image_tag("/images/icons/male.png")
    else
      image_tag("/images/icons/rainbow.png")
    end
  end
  
  def fone_column(record)
    "(#{record.fone_ddd}) #{record.fone_str}"
  end
end