# app/helpers/dashboard_helper.rb
module DashboardHelper
  def calcular_progresso_mes(habito, mes, ano)
    primeiro_dia = Date.new(ano, mes, 1)
    ultimo_dia = primeiro_dia.end_of_month

    agendados = 0
    feitos = 0

    (primeiro_dia..ultimo_dia).each do |dia|
      if habito.fazer_hoje?(dia)
        agendados += 1
        if habito.feito_no_dia?(dia)
          feitos += 1
        end
      end
    end

    {
      agendados: agendados,
      feitos: feitos,
      percentual: agendados > 0 ? (feitos.to_f / agendados * 100).round : 0
    }
  end
end