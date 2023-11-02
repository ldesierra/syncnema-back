class ContentStreamingSite < ApplicationRecord
  belongs_to :streaming_site
  belongs_to :content
end
