require "test_helper"

class ZoneTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/zones")
      .to_return(body: {data: [{id: '1', type: 'zones', attributes: {id: 1, name: 'Germination'}}, {id: '2', type: 'zones', attributes: {id: 2, name: 'Propagation'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/zones/2")
      .to_return(body: {data: {id: '2', type: 'zones', attributes: {id: 2, name: 'Propagation'}}}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/zones?filter[seeding_unit_id]=100")
      .to_return(body: {data: [{id: '2', type: 'zones', attributes: {id: 2, name: 'Propagation'}}]}.to_json)
  end

  def test_finding_all_zones
    zones = ArtemisApi::Zone.find_all(facility_id: @facility.id, client: @client)
    assert_equal 2, zones.count
  end

  def test_finding_all_zones_through_facility
    zones = @facility.zones
    assert_equal 2, zones.count
  end

  def test_finding_a_specific_zone
    zone = ArtemisApi::Zone.find(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 'Propagation', zone.name
  end

  def test_finding_a_specific_zone_through_facility
    zone = @facility.zone(2)
    assert_equal 'Propagation', zone.name
  end

  def test_filtering_zones_by_seeding_unit_id
    zones = ArtemisApi::Zone.find_all(facility_id: @facility.id, client: @client, filters: {seeding_unit_id: 100})
    assert_equal 1, zones.count
  end
end
