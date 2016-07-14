class Workout < ActiveRecord::Base
  belongs_to :runner
  has_many :run_types
end