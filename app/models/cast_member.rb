class CastMember < ApplicationRecord
  validates_presence_of :name

  belongs_to :content
end
