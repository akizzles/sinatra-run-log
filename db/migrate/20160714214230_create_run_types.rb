class CreateRunTypes < ActiveRecord::Migration
  def change
    create_table :run_types do |t|
      t.string :name
      t.integer :workout_id
    end
  end
end
