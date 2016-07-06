class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :run_type
      t.float :distance
      t.date :day
      t.string :time
      t.integer :runner_id
    end
  end
end
