class User < ApplicationRecord
  validates_presence_of :email, :external_id

  has_many :ratings
end
