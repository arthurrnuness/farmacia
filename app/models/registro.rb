class Registro < ApplicationRecord
  belongs_to :atividade 
  
  validates :data, presence: true

  validates :atividade_id, uniqueness: { scope: :data, message: "já tem registro para este dia" }
  

 
end
