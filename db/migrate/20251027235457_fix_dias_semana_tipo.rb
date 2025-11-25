class FixDiasSemanaTipo < ActiveRecord::Migration[7.0]
  def up
    # Limpar dados existentes primeiro
    execute "UPDATE atividades SET dias_semana = '[]'"
    
    # Converter coluna
    change_column :atividades, :dias_semana, :json, default: [], using: 'dias_semana::json'
  end
  
  def down
    change_column :atividades, :dias_semana, :text
  end
end