class AtividadesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_objetivo
  before_action :set_atividade, only: %i[ show edit update destroy ]

  # GET /atividades or /atividades.json
  def index
    @atividades = @objetivo.atividades.order(created_at: :desc)
  end

  # GET /atividades/1 or /atividades/1.json
  def show
    @registros = @atividade.registros.order(data: :desc).limit(30)
  end

  # GET /atividades/new
  def new
    @atividade = @objetivo.atividades.build
  end

  # GET /atividades/1/edit
  def edit
  end

  # POST /atividades or /atividades.json
   def create
    @atividade = @objetivo.atividades.build(atividade_params)
    
    if @atividade.save
      redirect_to objetivo_atividade_path(@objetivo, @atividade), notice: 'Atividade criada com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  # PATCH/PUT /atividades/1 or /atividades/1.json
  def update
    if @atividade.update(atividade_params)
      redirect_to objetivo_atividade_path(@objetivo, @atividade), notice: 'Atividade atualizada!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  # DELETE /atividades/1 or /atividades/1.json
  def destroy
    @atividade.destroy!

    redirect_to objetivo_path(@objetivo), notice: 'Atividade removida!'

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objetivo
      @objetivo = current_user.objetivos.find(params[:objetivo_id])
    end
    
    def set_atividade
      @atividade = @objetivo.atividades.find(params[:id])
    end
    # Only allow a list of trusted parameters through.
    def atividade_params
      params.require(:atividade).permit(:nome, :descricao, :frequencia_semanal, :ativo, dias_semana: [])
    end
end
