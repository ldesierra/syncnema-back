class CastMemberInfoRetrievalJob
  include Sidekiq::Job

  def perform(record_id, data)
    record = Content.find(record_id)

    cast_info = WikidataExpand.call(data.map { |s| s['node']['name']['id'] })

    cast_info.each do |cast_member|
      actor = CastMember.find_or_initialize_by(name: cast_member[:actorName].to_s)
      actor.update(
        occupations: cast_member[:occupation].to_s&.split('|'),
        image: cast_member[:actorImage].to_s,
        awards: cast_member[:actorAwards].to_s&.split('|')
      )

      join = CastMemberContent.find_or_initialize_by(content_id: record.id, cast_member_id: actor.id)
      join.save
    end
  end
end
