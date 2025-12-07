class HabitosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habito, only: %i[ show edit update destroy progresso ]

  # GET /habitos
  def index
    @habitos = current_user.habitos.order(created_at: :desc)
  end

  # GET /habitos/1
  def show
    # Mês e ano para o calendário
    @mes = params[:mes] ? params[:mes].to_i : Date.today.month
    @ano = params[:ano] ? params[:ano].to_i : Date.today.year
    @data_inicio = Date.new(@ano, @mes, 1)
    @data_fim = @data_inicio.end_of_month

    # Todos os dias do mês
    @dias_mes = (@data_inicio..@data_fim).to_a

    # Registros do mês selecionado, com observações
    @registros_mes = @habito.registros
      .where(data: @data_inicio..@data_fim)
      .order(data: :desc)

    # Registros com observação, agrupados por dia
    @registros_com_observacao = @habito.registros
      .where(data: @data_inicio..@data_fim)
      .where.not(observacao: [nil, ''])
      .order(data: :desc)
      .group_by(&:data)
  end

  # GET /habitos/new
  def new
    @habito = current_user.habitos.build
  end

  # GET /habitos/1/edit
  def edit
  end

  # POST /habitos
  def create
    @habito = current_user.habitos.build(habito_params.except(:tag_ids, :new_tag_name, :new_tag_cor))

    # Processar tags
    process_tags

    if @habito.save
      redirect_to dashboard_path, notice: 'Hábito criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /habitos/1
  def update
    # Processar tags
    process_tags

    if @habito.update(habito_params.except(:tag_ids, :new_tag_name, :new_tag_cor))
      redirect_to dashboard_path, notice: 'Hábito atualizado!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /habitos/1
  def destroy
    @habito.destroy!
    redirect_to habitos_path, notice: 'Hábito removido!'
  end

  # GET /habitos/1/progresso
  def progresso
    progresso = @habito.progresso_semana

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          feitos: progresso[:feitos],
          meta: progresso[:meta],
          percentual: progresso[:percentual]
        }
      end
    end
  end

  private
    def set_habito
      @habito = current_user.habitos.find(params[:id])
    end

    def habito_params
      params.require(:habito).permit(:nome, :descricao, :frequencia_semanal, :ativo, :new_tag_name, :new_tag_cor, dias_semana: [], tag_ids: [])
    end

    def process_tags
      # Adicionar tags existentes
      if params[:habito][:tag_ids].present?
        tag_ids = params[:habito][:tag_ids].reject(&:blank?).map(&:to_i)
        @habito.tag_ids = tag_ids
      end

      # Criar nova tag se fornecida
      if params[:habito][:new_tag_name].present?
        tag = current_user.tags.find_or_create_by(nome: params[:habito][:new_tag_name]) do |t|
          t.cor = params[:habito][:new_tag_cor].presence || Tag::CORES_PADRAO.sample
        end
        @habito.tags << tag unless @habito.tags.include?(tag)
      end
    end
end
