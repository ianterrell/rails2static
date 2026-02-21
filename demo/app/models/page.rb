class Page < ApplicationRecord
  def to_param
    slug
  end
end
