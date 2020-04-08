module ArtemisApi
  class Facility < ArtemisApi::Model
    json_type 'facilities'

    def self.find(id, client, include: nil, force: false)
      client.find_one(self.json_type, id, include: include, force: force)
    end

    def self.find_all(client, include: nil)
      client.find_all(self.json_type, include: include)
    end

    def zones
      ArtemisApi::Zone.find_all(id, client)
    end

    def find_zone(zone_id)
      ArtemisApi::Zone.find(zone_id, id, client)
    end

    def batches
      ArtemisApi::Batch.find_all(id, client)
    end

    def stages
      ArtemisApi::Stage.find_all(id, client)
    end

    def find_stage(stage_id)
      ArtemisApi::Stage.find(stage_id, id, client)
    end

    def find_batch(batch_id)
      ArtemisApi::Batch.find(batch_id, id, client)
    end
  end
end
