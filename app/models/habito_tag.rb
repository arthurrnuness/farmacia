class HabitoTag < ApplicationRecord
  self.table_name = 'habitos_tags'

  belongs_to :habito
  belongs_to :tag
end
