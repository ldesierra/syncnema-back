class StreamingSite < ApplicationRecord
  validates_presence_of :name, :kind

  belongs_to :content
end
