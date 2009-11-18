class Admin::AdministradoresController < Admin::AdminController
  # GET /administradores
  # GET /administradores.xml
  def index
    @administradores = Administrador.find(:all, :order => "id ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @administradores }
    end
  end

  # GET /administradores/new
  # GET /administradores/new.xml
  def new
    @administrador = Administrador.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @administrador }
    end
  end

  # GET admin/administradores/1/edit
  def edit
    @administrador = Administrador.find(params[:id])
  end

  # POST /administradores
  # POST /administradores.xml
  def create
    @administrador = Administrador.new(params[:administrador])

    respond_to do |format|
      if @administrador.save
        flash[:notice] = "Administrador criado com sucesso."
        format.html { redirect_to(admin_administradores_path) }
        format.xml  { render :xml => @administrador, :status => :created, :location => @administrador }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @administrador.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT admin/administradores/1
  # PUT admin/administradores/1.xml
  def update
    @administrador = Administrador.find(params[:id])

    respond_to do |format|
      if @administrador.update_attributes(params[:administrador])
        flash[:notice] = "Administrador atualizado com sucesso."
        format.html { redirect_to(admin_administradores_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @administrador.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /administradores/1
  # DELETE /administradores/1.xml
  def destroy
    @administrador = Administrador.find(params[:id])
    @administrador.destroy

    respond_to do |format|
      format.html { redirect_to(admin_administradores_path) }
      format.xml  { head :ok }
    end
  end
end