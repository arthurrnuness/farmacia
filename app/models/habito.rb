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

  def feito_no_dia?(data)
    registros.exists?(data: data, concluido: true)
  end

  def progresso_semana
    inicio = Date.today.beginning_of_week
    fim = Date.today.end_of_week

    feitos = registros.where(data: inicio..fim, concluido: true).count

    {
      feitos: feitos,
      meta: frequencia_semanal,
      percentual: frequencia_semanal > 0 ? (feitos.to_f / frequencia_semanal * 100).round : 0
    }
  end

  def meta_semanal_atingida?
    progresso_semana[:feitos] >= frequencia_semanal
  end
end
