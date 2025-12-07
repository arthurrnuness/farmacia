class RemoveObjetivoFromAtividades < ActiveRecord::Migration[8.1]
  def change
    # Adiciona user_id às atividades
    add_reference :atividades, :user, foreign_key: true

    # Migra os dados: copia user_id do objetivo para atividade
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE atividades
          SET user_id = objetivos.user_id
          FROM objetivos
          WHERE atividades.objetivo_id = objetivos.id
        SQL
      end
    end

    # Torna user_id obrigatório
    change_column_null :atividades, :user_id, false

    # Remove a referência ao objetivo
    remove_reference :atividades, :objetivo, foreign_key: true
  end
end
