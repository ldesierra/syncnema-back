Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://syncnema.vercel.app',
            'https://syncnema-git-sa-27-flocarle.vercel.app',
            'http://localhost:3000'

    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             expose: %w[Authorization Set-Cookie],
             credentials: true
  end
end
