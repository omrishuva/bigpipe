class Book < Entity

  attr_accessor :id, :title, :author, :published_on, :description, :created_at, :updated_at

  validates :title, presence: true

end
