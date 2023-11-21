# spec/integration/contents_spec.rb
require 'swagger_helper'

RSpec.describe 'Contents API', type: :request do

    path '/contents/{id}' do

        get 'Retrieves a specific content' do
          tags 'Contents'
          produces 'application/json'
          parameter name: :id, in: :path, type: :string

          response '200', 'Content Found' do
            schema type: :object,
              properties: {
                id: { type: :integer, nullable: true },
                title: { type: :string, nullable: true },
                image_url: { type: :string, nullable: true },
                trailer_url: { type: :string, nullable: true },
                director: { type: :string, nullable: true },
                creator: { type: :string, nullable: true },
                combined_plot: { type: :string, nullable: true },
                combined_release_date: { type: :string, nullable: true },
                combined_genres: { type: :string, nullable: true },
                combined_budget: { type: :integer, nullable: true },
                combined_revenue: { type: :integer, nullable: true },
                combined_runtime: { type: :integer, description: 'Combined runtime of the content in seconds', nullable: true },
                total_rating: { type: :number, nullable: true },
                content_rating: { type: :string, nullable: true },
                rating: { type: :number, nullable: true },
                trivia: { type: :string, nullable: true },
                quotes: { type: :string, nullable: true },
                cast: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      name: { type: :string, nullable: true },
                      awards: { type: :array, items: { type: :string, nullable: true }, nullable: true },
                      image: { type: :string, nullable: true }
                    }
                  }
                },
                platforms: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      name: { type: :string, nullable: true },
                      image: { type: :string, nullable: true }
                    }
                  }
                }
              }

            run_test!
          end
    
          response '404', 'Content Not Found' do
            let(:id) { 'invalid_id' }
          
            schema type: :object,
              properties: {
                error: { type: :string }
              },
              required: ['error']
        
            run_test!
          end
        end
      end

  path '/contents' do

    get 'Retrieves a list of contents' do
      tags 'Contents'
      produces 'application/json'
      parameter name: :genres, in: :query, type: :array, items: { type: :string }
      parameter name: :platforms, in: :query, type: :array, items: { type: :string }
      parameter name: :page, in: :query, type: :integer
      parameter name: :size, in: :query, type: :integer
      parameter name: :query, in: :query, type: :string
      parameter name: :type, in: :query, type: :string

      response '200', 'list of contents' do
        schema type: :object,
          properties: {
            records: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  score: { type: :number },
                  record: { 
                    type: :object,
                    properties: {
                      id: { type: :string },
                      title: { type: :string },
                      image_url: { type: :string, nullable: true }
                    }
                  }
                }
              }
            },
            total: { type: :integer },
            page: { type: :integer }
          }

        let(:genres) { ['action', 'drama'] }
        let(:platforms) { ['netflix', 'hulu'] }
        let(:page) { 0 }
        let(:size) { 20 }
        let(:query) { 'test' }
        let(:type) { 'movie' }
        run_test!
      end
    end
  end

  path '/provenance' do

    get 'Retrieves the provenance data in XML format' do
      tags 'Contents'
      produces 'application/xml'

      response '200', 'provenance data found' do
        run_test!
      end
    end
  end

end
