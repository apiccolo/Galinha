namespace :galinha do

  namespace :db_updates do

    desc "Ajustes em produtos_quantidades"
    task :pq_ajustes => :environment do
      Pedido.all.each do |p|
        for r in p.produtos_quantidades
          if r.preco_unitario.blank?
            if (p.id < 6583)
              preco = 29.9
            elsif (p.id < 30000) #ultimo ID antes de migrar
              estados_caros = %w(AM CE MA PI PA RN RO)
              if (estados_caros.include?(p.entrega_estado))
                preco = 37.9
              else
                preco = 32.9
              end
            end
            preco += 1.5 if r.presente
            r.update_attribute(:preco_unitario, preco)
          end
        end
      end
    end
    
  end#namespace
end