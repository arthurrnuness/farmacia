# app/controllers/registros_controller.rb
class RegistrosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_registro, only: [:edit, :update]
  before_action :set_habito_para_novo, only: [:new]

  def new
    @registro = @habito.registros.build
    @registro.data = params[:data] ? Date.parse(params[:data]) : Date.today
    @registro.concluido = false
  end

  def create
    habito_id = registro_params[:habito_id] || params[:habito_id]
    @habito = Habito.find(habito_id)

    unless @habito.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end

    @registro = @habito.registros.build(registro_params.except(:habito_id))

    if @registro.save
      redirect_to dashboard_path, notice: '✅ Registro criado!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @registro já definido
  end

  def update
    if @registro.update(registro_params)
      redirect_to dashboard_path, notice: '✅ Atualizado!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle
    @habito = Habito.find(params[:habito_id])

    unless @habito.user == current_user
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Acesso negado' }
        format.json { render json: { success: false, error: 'Acesso negado' }, status: :forbidden }
      end
      return
    end

    data = params[:data] ? Date.parse(params[:data]) : Date.today
    registro = @habito.registros.find_by(data: data)

    if registro
      registro.update!(concluido: !registro.concluido)
      concluido = registro.concluido?
      message = concluido ? '✅ Marcado!' : '❌ Desmarcado'
    else
      registro = @habito.registros.create!(data: data, concluido: true)
      concluido = true
      message = '✅ Marcado!'
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: dashboard_path, notice: message }
      format.json { render json: { success: true, concluido: concluido, message: message } }
    end
  end

  def editar_ou_criar
    @habito = Habito.find(params[:habito_id])

    unless @habito.user == current_user
      render json: { success: false, error: 'Acesso negado' }, status: :forbidden
      return
    end

    data = params[:data] ? Date.parse(params[:data]) : Date.today
    registro = @habito.registros.find_by(data: data)

    # Se não existe, criar um novo registro
    unless registro
      registro = @habito.registros.create!(
        data: data,
        concluido: false,
        observacao: ''
      )
    end

    render json: { success: true, registro_id: registro.id }
  end

  private

  def set_registro
    @registro = Registro.find(params[:id])

    unless @registro.habito.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end
  end

  def set_habito_para_novo
    @habito = Habito.find(params[:habito_id])

    unless @habito.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end
  end

  def registro_params
    params.require(:registro).permit(:data, :concluido, :observacao, :habito_id)
  end
end