class ChatGpt < ApplicationService
  def initialize(query)
    @query = query
  end

  def call
    model = 'gpt-4'
    api_url = 'https://api.openai.com/v1/chat/completions'

    body = {
      model: model,
      messages: [{ role: 'user', content: @query }]
    }
    response = HTTParty.post(
      api_url,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{ENV['GPT_API_KEY']}"},
      timeout: 30
    )
    raise response['error']['message'] unless response.code == 200

    response['choices'][0]['message']['content']
  end
end
