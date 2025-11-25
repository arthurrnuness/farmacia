# app/controllers/registros_controller.rb
class RegistrosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_registro, only: [:edit, :update]
  before_action :set_atividade_para_novo, only: [:new]
  
  def new
    @registro = @atividade.registros.build
    @registro.data = params[:data] ? Date.parse(params[:data]) : Date.today
    @registro.concluido = false
  end
  
  def create
    atividade_id = registro_params[:atividade_id] || params[:atividade_id]
    @atividade = Atividade.find(atividade_id)
    
    unless @atividade.objetivo.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end
    
    @registro = @atividade.registros.build(registro_params.except(:atividade_id))
    
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
    @atividade = Atividade.find(params[:atividade_id])
    
    unless @atividade.objetivo.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end
    
    data = params[:data] ? Date.parse(params[:data]) : Date.today
    registro = @atividade.registros.find_by(data: data)
    
    if registro
      registro.update!(concluido: !registro.concluido)
      message = registro.concluido? ? '✅ Marcado!' : '❌ Desmarcado'
    else
      @atividade.registros.create!(data: data, concluido: true)
      message = '✅ Marcado!'
    end
    
    redirect_back fallback_location: dashboard_path, notice: message
  end
  
  private
  
  def set_registro
    @registro = Registro.find(params[:id])
    
    unless @registro.atividade.objetivo.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end
  end
  
  def set_atividade_para_novo
    @atividade = Atividade.find(params[:atividade_id])
    
    unless @atividade.objetivo.user == current_user
      redirect_to root_path, alert: 'Acesso negado'
      return
    end
  end
  
  def registro_params
    params.require(:registro).permit(:data, :concluido, :observacao, :atividade_id)
  end
end