# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name ['syncnema', Rails.env, self.base_class.to_s.pluralize.underscore].join('_')

    include Indexing

    after_touch :index_document
    after_commit :index_document, on: %i[create update]
    after_commit :delete_document, on: :destroy
  end

  module Indexing
    def as_indexed_json(options={})
      self.as_json(root: false,
        only: %i[
          title,
          adult
        ]
      )
    end

    def index_document
      self.reload

      self.__elasticsearch__.index_document
    rescue => e
      p "===index_document==ERROR==#{e.inspect}" unless Rails.env.test?
    end

    def delete_document
      self.__elasticsearch__.delete_document
    rescue => e
      p "===delete_document==ERROR==#{e.inspect}" unless Rails.env.test?
    end
  end
end
