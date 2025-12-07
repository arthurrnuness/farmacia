class Registro < ApplicationRecord
  belongs_to :habito

  validates :data, presence: true
  validates :habito_id, uniqueness: { scope: :data, message: "já tem registro para este dia" }
end
