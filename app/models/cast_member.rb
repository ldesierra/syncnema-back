class CastMember < ApplicationRecord
  validates_presence_of :name

  has_many :cast_member_contents
  has_many :contents, through: :cast_member_contents
end
