class User < ApplicationRecord
  validates_presence_of :email, :external_id
  validates_uniqueness_of :external_id

  has_many :ratings, dependent: :destroy
end
