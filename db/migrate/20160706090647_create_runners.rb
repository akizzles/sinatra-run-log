class CreateRunners < ActiveRecord::Migration
  def change
    create_table :runners do |t|
      t.string :username
      t.string :password_digest
    end
  end
end
