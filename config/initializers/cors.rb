Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['APP_HOST'] || 'http://localhost:3000', 'http://localhost:3000'

    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             expose: %w[Authorization Set-Cookie],
             credentials: true
  end
end
