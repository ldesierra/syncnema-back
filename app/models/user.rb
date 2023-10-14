class User < ApplicationRecord
  validates_presence_of :email, :external_id
end
