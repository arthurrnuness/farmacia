class RenameAtividadesToHabitos < ActiveRecord::Migration[8.1]
  def change
    rename_table :atividades, :habitos
    rename_column :registros, :atividade_id, :habito_id
  end
end
