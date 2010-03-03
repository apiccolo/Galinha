# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100225152516) do

  create_table "administradores", :force => true do |t|
    t.string   "nome"
    t.string   "email"
    t.string   "senha"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "combo_tem_produtos", :id => false, :force => true do |t|
    t.integer "combo_id"
    t.integer "produto_id"
  end

  create_table "descontos", :force => true do |t|
    t.string   "codigo",        :limit => 50
    t.string   "email"
    t.integer  "valor"
    t.datetime "valido_ate"
    t.integer  "pedido_id"
    t.datetime "usado_em"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "minimo_pedido",               :default => 0.0
  end

  add_index "descontos", ["codigo"], :name => "index_descontos_on_codigo"

  create_table "pedidos", :force => true do |t|
    t.integer  "pessoa_id"
    t.string   "status",              :limit => 30,  :default => "PEDIDO"
    t.string   "forma_pgmto",         :limit => 100, :default => "INDEFINIDO"
    t.float    "frete",                              :default => 0.0
    t.float    "desconto",                           :default => 0.0
    t.datetime "data_pedido"
    t.datetime "data_pgmto"
    t.datetime "data_envio"
    t.datetime "data_recebimento"
    t.string   "entrega_nome_pacote", :limit => 50
    t.string   "entrega_endereco",    :limit => 100
    t.string   "entrega_numero",      :limit => 10
    t.string   "entrega_complemento"
    t.string   "entrega_bairro",      :limit => 50
    t.string   "entrega_cep",         :limit => 10
    t.string   "entrega_cidade",      :limit => 50
    t.string   "entrega_estado",      :limit => 2
    t.string   "codigo_postagem",     :limit => 50
    t.text     "obs"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "frete_tipo",          :limit => 20,  :default => "padrao"
    t.boolean  "reenviado",                          :default => false
    t.datetime "reenviado_em"
    t.string   "nota_fiscal",         :limit => 50
    t.integer  "reenvio",                            :default => 0
    t.datetime "data_nf"
  end

  add_index "pedidos", ["pessoa_id"], :name => "index_pedidos_on_pessoa_id"
  add_index "pedidos", ["status"], :name => "index_pedidos_on_status"

  create_table "pessoas", :force => true do |t|
    t.string   "nome",               :limit => 100
    t.string   "email",              :limit => 100
    t.string   "chave_cookie"
    t.string   "sexo",               :limit => 1,   :default => "m"
    t.date     "nascimento"
    t.string   "cpf",                :limit => 12
    t.string   "rg",                 :limit => 20
    t.string   "fone_ddd",           :limit => 5
    t.string   "fone_str",           :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cnpj",               :limit => 30
    t.string   "inscricao_estadual", :limit => 20
    t.string   "como_conheceu",      :limit => 30
  end

  add_index "pessoas", ["chave_cookie"], :name => "index_pessoas_on_chave_cookie"
  add_index "pessoas", ["email"], :name => "index_pessoas_on_email"
  add_index "pessoas", ["nome"], :name => "index_pessoas_on_nome"

  create_table "produtos", :force => true do |t|
    t.string  "nome"
    t.text    "descricao"
    t.boolean "disponivel",                      :default => true
    t.integer "qtd_estoque",                     :default => 0
    t.float   "peso"
    t.string  "tamanho"
    t.float   "preco",                           :default => 29.9
    t.float   "plus_presente",                   :default => 0.5
    t.string  "imagem_pequena"
    t.string  "descricao_simples", :limit => 30
    t.float   "preco_fiscal",                    :default => 0.0
    t.string  "type",              :limit => 20
    t.float   "desconto",                        :default => 0.0
  end

  add_index "produtos", ["nome"], :name => "index_produtos_on_nome"
  add_index "produtos", ["preco"], :name => "index_produtos_on_preco"

  create_table "produtos_quantidades", :force => true do |t|
    t.integer  "pedido_id"
    t.integer  "produto_id"
    t.integer  "qtd"
    t.boolean  "presente",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "preco_unitario"
  end

  add_index "produtos_quantidades", ["pedido_id"], :name => "index_produtos_quantidades_on_pedido_id"
  add_index "produtos_quantidades", ["produto_id"], :name => "index_produtos_quantidades_on_produto_id"

  create_table "retornos_pgmtos", :force => true do |t|
    t.integer  "pedido_id"
    t.string   "transacaoid",   :limit => 40
    t.string   "tipopagamento", :limit => 50
    t.string   "status",        :limit => 50
    t.string   "tipofrete",     :limit => 2
    t.integer  "numitens"
    t.text     "demais"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "retornos_pgmtos", ["pedido_id"], :name => "index_retornos_pgmtos_on_pedido_id"
  add_index "retornos_pgmtos", ["transacaoid"], :name => "index_retornos_pgmtos_on_transacaoid"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["var"], :name => "index_settings_on_var"

  create_table "sugestoes", :force => true do |t|
    t.integer "produto_id"
    t.integer "produto_sugerido_id"
    t.integer "position"
  end

end
