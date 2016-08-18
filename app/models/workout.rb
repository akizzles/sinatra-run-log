class Workout < ActiveRecord::Base
  belongs_to :runner
  has_one :run_type

    def slug
    self.name.downcase.gsub(" ","-")
  end

  def self.find_by_slug(slug)
    Workout.all.find{|workout| workout.run_types[0].name.slug == slug}
  end
end