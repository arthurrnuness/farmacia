class Tag < ApplicationRecord
  belongs_to :user
  has_many :habitos_tags, class_name: 'HabitoTag', dependent: :destroy
  has_many :habitos, through: :habitos_tags

  validates :nome, presence: true, uniqueness: { scope: :user_id }

  # Cores padrão para tags
  CORES_PADRAO = [
    '#6c757d', # cinza
    '#007bff', # azul
    '#28a745', # verde
    '#dc3545', # vermelho
    '#ffc107', # amarelo
    '#17a2b8', # ciano
    '#6f42c1', # roxo
    '#fd7e14', # laranja
    '#e83e8c'  # rosa
  ].freeze
end
