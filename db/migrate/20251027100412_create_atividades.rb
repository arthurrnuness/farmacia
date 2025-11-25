class CreateAtividades < ActiveRecord::Migration[8.1]
  def change
    create_table :atividades do |t|
      t.references :objetivo, null: false, foreign_key: true
      t.string :nome
      t.text :descricao
      t.integer :frequencia_semanal
      t.text :dias_semana
      t.boolean :ativo

      t.timestamps
    end
  end
end
