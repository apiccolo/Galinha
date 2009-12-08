class Admin::ProdutosController < Admin::AdminController
  def index
    @produtos = Produto.paginate(:all, :page => params[:page], :per_page => 30, :order => "id DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @produtos }
    end
  end

  # GET /produtos/new
  # GET /produtos/new.xml
  def new
    @produto = ProdutoSimples.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @produto }
    end
  end
  
  def new_combo
    @produto = ProdutoCombo.new
    @produtos = ProdutoSimples.all
    respond_to do |format|
      format.html # new_combo.html.erb
      format.xml  { render :xml => @produto }
    end
  end

  # GET admin/produtos/1/edit
  def edit
    @produto = ProdutoSimples.find(params[:id])
  end

  def edit_combo
    @produto = ProdutoCombo.find(params[:id])
    @produtos = ProdutoSimples.all
  end

  # POST /produtos
  # POST /produtos.xml
  def create
    @produto = ProdutoSimples.new(params[:produto_simples])
    respond_to do |format|
      if @produto.save
        flash[:notice] = "Produto criado com sucesso."
        format.html { redirect_to(admin_produtos_path) }
        format.xml  { render :xml => @produto, :status => :created, :location => @produto }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @produto.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def create_combo
  #  render :text => params.inspect
    @produto = ProdutoCombo.new(params[:produto_combo])
    @produtos = ProdutoSimples.all
    respond_to do |format|
      if @produto.save
        flash[:notice] = "Combo criado com sucesso."
        format.html { redirect_to(admin_produtos_path) }
        format.xml  { render :xml => @produto, :status => :created, :location => @produto }
      else
        format.html { render :action => "new_combo" }
        format.xml  { render :xml => @produto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT admin/produtos/1
  # PUT admin/produtos/1.xml
  def update
    @produto = ProdutoSimples.find(params[:id])
    respond_to do |format|
      if @produto.update_attributes(params[:produto_simples])
        flash[:notice] = "Produto atualizado com sucesso."
        format.html { redirect_to(admin_produtos_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @produto.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update_combo
    @produto = ProdutoCombo.find(params[:id])
    respond_to do |format|
      if @produto.update_attributes(params[:produto_combo])
        flash[:notice] = "Combo atualizado com sucesso."
        format.html { redirect_to(admin_produtos_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_combo" }
        format.xml  { render :xml => @produto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /produtos/1
  # DELETE /produtos/1.xml
  def destroy
    @produto = Produto.find(params[:id])
    @produto.destroy
    respond_to do |format|
      format.html { redirect_to(admin_produtos_path) }
      format.xml  { head :ok }
    end
  end
  
  def relacionar
    @produto = Produto.find(params[:id])
    @demais_produtos = Produto.find(:all, :conditions => ["produtos.id <> ?", params[:id]])
    if params[:produto_id] and params[:novo]
      @produto.produtos_relacionados << Produto.find(params[:produto_id])
    end
  end
  
end