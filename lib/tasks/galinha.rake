namespace :galinha do

  namespace :db_updates do

   #desc "Ajustes em produtos_quantidades"
   #task :pq_ajustes => :environment do
   #  Pedido.all.each do |p|
   #    for r in p.produtos_quantidades
   #      if r.preco_unitario.blank?
   #        preco = 32.9
   #        if (p.id < 6583)
   #          preco = 29.9
   #        else #if (p.id >= 6583) and (p.id <= 28179) #ultimo ID antes de migrar
   #          estados_caros = %w(AM CE MA PI PA RN RO)
   #          if (estados_caros.include?(p.entrega_estado))
   #            preco = 37.9
   #          else
   #            preco = 32.9
   #          end
   #        end
   #        preco += 1.5 if r.presente
   #        r.update_attribute(:preco_unitario, preco)
   #      end
   #    end
   #  end
   #end
    
   desc "Ajustes em pedidos[data_pgmto]"
   task :data_pgmto => :environment do
     RetornosPgmto.find(:all, 
                        :select => 'DISTINCT pedido_id, created_at', 
                        :conditions => ["status = 'Aprovado'"], 
                        :include => [:pedido],
                        :order => "pedido_id DESC").each do |rp|
       if rp and rp.pedido
         pedido = rp.pedido
         if pedido.data_pgmto.blank?
           pedido.update_attribute(:data_pgmto, rp.created_at)
           puts "Pedido #{pedido.id} atualizado - pago em #{rp.created_at}"
         else
           puts "Já preenchida!"
         end
      else
        puts "Nothing found...!"
      end
     end
   end
    
  end#namespace
end