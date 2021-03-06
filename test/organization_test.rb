require "test_helper"

class OrganizationTest < Minitest::Test
  def setup
    get_client

    stub_request(:get, 'http://localhost:3000/api/v3/organizations')
      .to_return(body: {data: [{id: '1', type: 'organizations', attributes: {id: 1, name: 'Sky Fresh'}}, {id: '2', type: 'organizations', attributes: {id: 2, name: 'Rare Dankness'}}]}.to_json)
  end

  def test_finding_all_organizations
    organizations = ArtemisApi::Organization.find_all(client: @client)
    assert_equal 2, organizations.count
  end

  def test_finding_a_specific_organization
    stub_request(:get, 'http://localhost:3000/api/v3/organizations/2')
      .to_return(body: {data: {id: '2', type: 'organizations', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)

    org = ArtemisApi::Organization.find(id: 2, client: @client)
    assert_equal 'Rare Dankness', org.name
  end

  def test_finding_a_specific_org_thats_already_in_memory
    ArtemisApi::Organization.find_all(client: @client)
    org = ArtemisApi::Organization.find(id: 2, client: @client)
    assert_equal 'Rare Dankness', org.name
  end

  def test_getting_orgs_with_facilities_included
    stub_request(:get, 'http://localhost:3000/api/v3/organizations/2?include=facilities')
      .to_return(body: {data: {id: '2', type: 'organizations', attributes: {id: 2, name: 'Rare Dankness'}}, included: [{id: 1, type: "facilities", attributes: {id: 1, name: 'Sky Fresh'}}]}.to_json)

    org = ArtemisApi::Organization.find(id: 2, client: @client, include: 'facilities')
    facility = ArtemisApi::Facility.find(id: 1, client: @client)
    assert_equal 'Rare Dankness', org.name
    assert_equal 'Sky Fresh', facility.name
  end
end
