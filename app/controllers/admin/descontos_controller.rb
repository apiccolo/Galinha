class Admin::DescontosController < Admin::AdminController
  # GET /descontos
  # GET /descontos.xml
  def index
    @descontos = Desconto.paginate(:all, :page => params[:page], :per_page => 30, :order => "id DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @descontos }
    end
  end

  # GET /descontos/1
  # GET /descontos/1.xml
  def show
    @desconto = Desconto.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @desconto }
    end
  end

  # GET /descontos/new
  # GET /descontos/new.xml
  def new
    @desconto = Desconto.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @desconto }
    end
  end

  # GET /descontos/1/edit
  def edit
    @desconto = Desconto.find(params[:id])
  end

  # POST /descontos
  # POST /descontos.xml
  def create
    @desconto = Desconto.new(params[:desconto])
    respond_to do |format|
      if @desconto.save
        flash[:notice] = 'Desconto criado com sucesso.'
        format.html { redirect_to(admin_descontos_path) }
        format.xml  { render :xml => @desconto, :status => :created, :location => @desconto }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @desconto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /descontos/1
  # PUT /descontos/1.xml
  def update
    @desconto = Desconto.find(params[:id])
    respond_to do |format|
      if @desconto.update_attributes(params[:desconto])
        flash[:notice] = 'Desconto atualizado com sucesso.'
        format.html { redirect_to(admin_descontos_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @desconto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /descontos/1
  # DELETE /descontos/1.xml
  def destroy
    @desconto = Desconto.find(params[:id])
    @desconto.destroy
    respond_to do |format|
      format.html { redirect_to(admin_descontos_path) }
      format.xml  { head :ok }
    end
  end
end
