class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :handle
      t.string :email
      t.boolean :admin

      t.timestamps
    end
  end
end
