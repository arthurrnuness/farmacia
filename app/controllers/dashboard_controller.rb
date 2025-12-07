class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Data selecionada (hoje por padrão)
    @data = params[:data] ? Date.parse(params[:data]) : Date.today

    # Mês e ano para o calendário
    @mes = params[:mes] ? params[:mes].to_i : @data.month
    @ano = params[:ano] ? params[:ano].to_i : @data.year

    @habitos = current_user.habitos.where(ativo: true).includes(:registros)

    # Hábitos do dia selecionado
    @habitos_hoje = @habitos.select { |habito| habito.fazer_hoje?(@data) }
  end

  def grid
    # Mês e ano para o calendário
    @mes = params[:mes] ? params[:mes].to_i : Date.today.month
    @ano = params[:ano] ? params[:ano].to_i : Date.today.year
    @data_inicio = Date.new(@ano, @mes, 1)
    @data_fim = @data_inicio.end_of_month

    @habitos = current_user.habitos.where(ativo: true).includes(:registros, :tags)

    # Calcular semana atual (domingo a sábado)
    hoje = Date.today
    inicio_semana = hoje - hoje.wday # Domingo
    fim_semana = inicio_semana + 6    # Sábado

    # Array com todos os dias do mês e da semana
    @dias_mes = (@data_inicio..@data_fim).to_a
    @dias_semana = (inicio_semana..fim_semana).to_a
  end

  def calendario
    @mes = params[:mes] ? params[:mes].to_i : Date.today.month
    @ano = params[:ano] ? params[:ano].to_i : Date.today.year

    @data_inicio = Date.new(@ano, @mes, 1)
    @data_fim = @data_inicio.end_of_month

    @habitos = current_user.habitos.where(ativo: true).includes(:registros)

    # Calcular status de cada dia do mês
    @dias_mes = (@data_inicio..@data_fim).map do |dia|
      habitos_dia = []
      total_habitos = 0
      feitos = 0

      @habitos.each do |habito|
        if habito.fazer_hoje?(dia)
          total_habitos += 1
          if habito.feito_no_dia?(dia)
            feitos += 1
          end
          habitos_dia << habito
        end
      end

      {
        dia: dia,
        total: total_habitos,
        feitas: feitos,
        percentual: total_habitos > 0 ? (feitos.to_f / total_habitos * 100).round : 0,
        habitos: habitos_dia
      }
    end
  end
end
