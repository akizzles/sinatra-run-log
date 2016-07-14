class CreateWorkouts < ActiveRecord::Migration
  def change
    create_table :workouts do |t|
      t.float :distance
      t.date :day
      t.string :time
      t.integer :runner_id
    end
  end
end
