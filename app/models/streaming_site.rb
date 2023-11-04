class StreamingSite < ApplicationRecord
  validates_presence_of :name, :kind

  has_many :content_streaming_sites
  has_many :contents, through: :content_streaming_sites
end
