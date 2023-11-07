class ChatgptQueriesJob
  include Sidekiq::Job

  def perform(record_id)
    record = Content.find(record_id)

    record.combine_genres
    record.combine_plots
  end
end
