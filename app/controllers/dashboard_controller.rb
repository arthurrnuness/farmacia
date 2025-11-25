class DashboardController < ApplicationController
    before_action :authenticate_user!


  def index
      # Data selecionada (hoje por padrão)
      @data = params[:data] ? Date.parse(params[:data]) : Date.today
      
      # Mês e ano para o calendário
      @mes = params[:mes] ? params[:mes].to_i : @data.month
      @ano = params[:ano] ? params[:ano].to_i : @data.year
      
      @objetivos = current_user.objetivos.where(ativo: true).includes(atividades: :registros)
      
      # Atividades do dia selecionado
      @atividades_hoje = []
      @objetivos.each do |objetivo|
        objetivo.atividades.where(ativo: true).each do |atividade|
          if atividade.fazer_hoje?(@data)
            @atividades_hoje << atividade
          end
        end
      end
    end
    def calendario
      @mes = params[:mes] ? params[:mes].to_i : Date.today.month
      @ano = params[:ano] ? params[:ano].to_i : Date.today.year
      
      @data_inicio = Date.new(@ano, @mes, 1)
      @data_fim = @data_inicio.end_of_month
      
      @objetivos = current_user.objetivos.where(ativo: true).includes(atividades: :registros)
      
      # Calcular status de cada dia do mês
      @dias_mes = (@data_inicio..@data_fim).map do |dia|
        atividades_dia = []
        total_atividades = 0
        feitas = 0
        
        @objetivos.each do |objetivo|
          objetivo.atividades.where(ativo: true).each do |atividade|
            if atividade.fazer_hoje?(dia)
              total_atividades += 1
              if atividade.feito_no_dia?(dia)
                feitas += 1
              end
              atividades_dia << atividade
            end
          end
        end
        
        {
          dia: dia,
          total: total_atividades,
          feitas: feitas,
          percentual: total_atividades > 0 ? (feitas.to_f / total_atividades * 100).round : 0,
          atividades: atividades_dia
        }
      end
    end

end
