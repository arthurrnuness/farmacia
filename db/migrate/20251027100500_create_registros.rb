class CreateRegistros < ActiveRecord::Migration[8.1]
  def change
    create_table :registros do |t|
      t.references :atividade, null: false, foreign_key: true
      t.date :data
      t.boolean :concluido
      t.text :observacao

      t.timestamps
    end
  end
end
