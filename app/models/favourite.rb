class Favourite < ApplicationRecord
  belongs_to :content
  belongs_to :user
end
