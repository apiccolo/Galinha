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
    @produto = Produto.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @produto }
    end
  end

  # GET admin/produtos/1/edit
  def edit
    @produto = Produto.find(params[:id])
  end

  # POST /produtos
  # POST /produtos.xml
  def create
    @produto = Produto.new(params[:produto])
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

  # PUT admin/produtos/1
  # PUT admin/produtos/1.xml
  def update
    @produto = Produto.find(params[:id])
    respond_to do |format|
      if @produto.update_attributes(params[:produto])
        flash[:notice] = "Produto atualizado com sucesso."
        format.html { redirect_to(admin_produtos_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
end