class ObjetivosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_objetivo, only: %i[ show edit update destroy ]

  # GET /objetivos or /objetivos.json
  def index
    @objetivos = current_user.objetivos.order(created_at: :desc)
  end

  # GET /objetivos/1 or /objetivos/1.json
  def show
    @atividades = @objetivo.atividades.order(created_at: :desc)
  end

  # GET /objetivos/new
  def new
    @objetivo = current_user.objetivos.build
  end

  # GET /objetivos/1/edit
  def edit
  end

  # POST /objetivos or /objetivos.json
  def create
    @objetivo = current_user.objetivos.build(objetivo_params)
    
    if @objetivo.save
      redirect_to @objetivo, notice: 'Objetivo criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /objetivos/1 or /objetivos/1.json
  def update
    if @objetivo.update(objetivo_params)
      redirect_to @objetivo, notice: 'Objetivo atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  # DELETE /objetivos/1 or /objetivos/1.json
  def destroy
    @objetivo.destroy!

    respond_to do |format|
      format.html { redirect_to objetivos_path, notice: "Objetivo apagado com sucesso!", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objetivo
      @objetivo = current_user.objetivos.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def objetivo_params
      params.expect(objetivo: [ :user_id, :nome, :descricao, :ativo ])
    end
end
