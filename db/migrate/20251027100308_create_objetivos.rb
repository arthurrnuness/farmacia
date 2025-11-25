class CreateObjetivos < ActiveRecord::Migration[8.1]
  def change
    create_table :objetivos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nome
      t.text :descricao
      t.boolean :ativo

      t.timestamps
    end
  end
end
