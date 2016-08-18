class CreateRunTypes < ActiveRecord::Migration
  def change
    create_table :run_types do |t|
      t.string :name
      t.belongs_to :workout
      t.integer :workout_id
      t.integer :runner_id
    end
  end
end
