settings = { url: 'https://elastic:qGd_hgPzRSUmnyn0qAbq@179.31.2.183:9200',
               transport_options: {
                 ssl: {
                   verify: false
                 }
                }
              }

Elasticsearch::Model.client = Elasticsearch::Client.new(settings)
