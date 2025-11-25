class Objetivo < ApplicationRecord
  belongs_to :user
  has_many :atividades, dependent: :destroy
  has_many :registros, through: :atividades
  
  validates :nome, presence: true
end
