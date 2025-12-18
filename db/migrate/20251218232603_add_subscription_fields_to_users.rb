class AddSubscriptionFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :premium, :boolean, default: false, null: false
    add_column :users, :trial_ends_at, :datetime
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_subscription_id, :string

    add_index :users, :stripe_customer_id
    add_index :users, :stripe_subscription_id
  end
end
