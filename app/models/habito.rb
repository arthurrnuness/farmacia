class Habito < ApplicationRecord
  belongs_to :user
  has_many :registros, dependent: :destroy
  has_many :habitos_tags, class_name: 'HabitoTag', dependent: :destroy
  has_many :tags, through: :habitos_tags

  validates :nome, presence: true

  def fazer_hoje?(data = Date.today)
    return false unless ativo?

    dia_semana = data.strftime('%A').downcase
    dias_semana.include?(dia_semana)
  end

  # Nova lógica: se existe registro = fez, se não existe = não fez
  # Ignora o campo 'concluido' - apenas a existência do registro importa
  def feito_no_dia?(data)
    registros.exists?(data: data)
  end

  def progresso_semana
    inicio = Date.today.beginning_of_week
    fim = Date.today.end_of_week

    # Nova lógica: conta apenas registros existentes (não importa o campo concluido)
    feitos = registros.where(data: inicio..fim).count

    {
      feitos: feitos,
      meta: frequencia_semanal,
      percentual: frequencia_semanal > 0 ? (feitos.to_f / frequencia_semanal * 100).round : 0
    }
  end

  def meta_semanal_atingida?
    progresso_semana[:feitos] >= frequencia_semanal
  end

  # Toggle: se existe registro, remove; se não existe, cria
  def toggle_dia(data)
    registro = registros.find_by(data: data)

    if registro
      registro.destroy
      false # retorna false indicando que foi removido
    else
      registros.create!(data: data, concluido: true) # mantém concluido para compatibilidade
      true # retorna true indicando que foi criado
    end
  end

  # Calcula taxa de conclusão de um mês específico
  def taxa_conclusao_mes(ano, mes)
    primeiro_dia = Date.new(ano, mes, 1)
    ultimo_dia = primeiro_dia.end_of_month
    hoje = Date.today

    agendados = 0
    feitos = 0

    (primeiro_dia..ultimo_dia).each do |dia|
      # Só conta dias que já passaram e que eram agendados
      if dia <= hoje && fazer_hoje?(dia)
        agendados += 1
        feitos += 1 if feito_no_dia?(dia)
      end
    end

    agendados > 0 ? (feitos.to_f / agendados * 100).round : 0
  end

  # Retorna registros de um mês específico
  def dias_no_mes(ano, mes)
    primeiro_dia = Date.new(ano, mes, 1)
    ultimo_dia = primeiro_dia.end_of_month

    registros.where(data: primeiro_dia..ultimo_dia).order(data: :desc)
  end

  # Retorna estatísticas detalhadas de um mês
  # Para estatísticas, considera o campo 'concluido' para permitir registros de dias não feitos com observações
  def estatisticas_mes(ano, mes)
    primeiro_dia = Date.new(ano, mes, 1)
    ultimo_dia = primeiro_dia.end_of_month
    hoje = Date.today

    total_dias_mes = (primeiro_dia..ultimo_dia).count
    dias_agendados_total = 0
    dias_agendados_passados = 0
    dias_feitos = 0
    dias_nao_feitos = 0

    # Série temporal para o gráfico
    serie_dias = []

    (primeiro_dia..ultimo_dia).each do |dia|
      agendado = fazer_hoje?(dia)
      # Para estatísticas, verifica também o campo concluido
      registro = registros.find_by(data: dia)
      feito = registro&.concluido? || false
      passado = dia <= hoje

      if agendado
        dias_agendados_total += 1
        if passado
          dias_agendados_passados += 1
          if feito
            dias_feitos += 1
          else
            dias_nao_feitos += 1
          end
        end
      end

      serie_dias << {
        data: dia,
        agendado: agendado,
        feito: feito,
        passado: passado
      }
    end

    taxa = dias_agendados_passados > 0 ? (dias_feitos.to_f / dias_agendados_passados * 100).round : 0

    {
      mes: mes,
      ano: ano,
      total_dias_mes: total_dias_mes,
      dias_agendados_total: dias_agendados_total,
      dias_agendados_passados: dias_agendados_passados,
      dias_feitos: dias_feitos,
      dias_nao_feitos: dias_nao_feitos,
      taxa_conclusao: taxa,
      serie_dias: serie_dias
    }
  end
end
