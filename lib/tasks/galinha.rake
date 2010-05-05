namespace :galinha do
  
  namespace :rotinas do
    
    desc "Cancela pedidos antigos não pagos"
    task :cancela_antigos => :environment do
      data = 45.days.ago
      Pedido.feitos_antes_de(data).com_status('aguardando_pagamento').find(:all, :include => :pessoa).each do |pedido|
        pedido.cancelar!
        puts "Pedido #{pedido.id}, feito em #{pedido.created_at.strftime('%d/%m/%Y')}, por #{pedido.pessoa.nome} (#{pedido.pessoa.email}) - CANCELADO!"
      end
    end
    
    desc "Encerra pedidos antigos enviados aos clientes e já recebidos"
    task :encerra_enviados => :environment do
      data = 30.days.ago
      Pedido.anteriores_a(data).com_status(%w(recebido_pelo_cliente produto_enviado_cod_postagem)).find(:all, :include => :pessoa).each do |pedido|
        pedido.encerrar!
        puts "Pedido #{pedido.id}, enviado em #{pedido.data_envio.strftime('%d/%m/%Y')}, comprado por #{pedido.pessoa.nome} (#{pedido.pessoa.email}) - ENCERRADO!"
      end
    end

    desc "Notifica compradores de boletos não pago"
    task :boletos_nao_pagos => :environment do
      data = 8.days.ago
      Pedido.feitos_dias_atras(data).com_status('aguardando_pagamento').forma_pgmto('Boleto').find(:all, :include => :pessoa).each do |pedido|
        pedido.notifica_retry_boleto
        puts "Pedido #{pedido.id}, feito em #{pedido.created_at.strftime('%d/%m/%Y')}, comprado por #{pedido.pessoa.nome} (#{pedido.pessoa.email}) - AVISO DE BOLETO NÃO PAGO!"
      end
    end
    
  end#namespace :rotinas

  namespace :db_updates do
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