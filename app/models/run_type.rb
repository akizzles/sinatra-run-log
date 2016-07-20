class RunType < ActiveRecord::Base
  belongs_to :workout

  def slug
    self.name.downcase.gsub(" ","-")
  end

  def self.find_by_slug(slug)
    RunType.all.find{|name| name.slug == slug}
  end
end