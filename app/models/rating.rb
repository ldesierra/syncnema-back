class Rating < ApplicationRecord
  belongs_to :content
  belongs_to :user

  validates_presence_of :score
  validates_inclusion_of :score, in: (1..10)

  scope :positive, -> { where("score > 5") }
  scope :negative, -> { where("score <= 5") }
end
