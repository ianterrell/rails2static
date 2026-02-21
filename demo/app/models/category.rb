class Category < ApplicationRecord
  has_and_belongs_to_many :posts

  def to_param
    slug
  end
end
