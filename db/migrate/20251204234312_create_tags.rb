class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :nome, null: false
      t.string :cor, default: '#6c757d'
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, [:user_id, :nome], unique: true
  end
end
