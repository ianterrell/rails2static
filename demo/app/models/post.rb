class Post < ApplicationRecord
  has_and_belongs_to_many :categories

  scope :published, -> { where(published: true).order(published_at: :desc) }

  def to_param
    slug
  end
end
