class Runner < ActiveRecord::Base
  has_many :workouts
  has_many :run_types, through: :workouts
  has_secure_password

end
