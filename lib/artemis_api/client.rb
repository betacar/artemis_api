module ArtemisApi
  class Client
    require 'oauth2'
    attr_reader :options, :objects, :access_token, :refresh_token, :oauth_client, :oauth_token

    def initialize(access_token, refresh_token, expires_in, created_at, options = {})
      options[:app_id] ||= ENV['ARTEMIS_OAUTH_APP_ID']
      options[:app_secret] ||= ENV['ARTEMIS_OAUTH_APP_SECRET']
      options[:base_uri] ||= ENV['ARTEMIS_BASE_URI']
      @options = options
      @access_token = access_token
      @refresh_token = refresh_token
      @expires_in = expires_in
      @created_at = created_at
      @expires_at = created_at.strftime('%s').to_i + expires_in

      @oauth_client = OAuth2::Client.new(@options[:app_id], @options[:app_secret], site: @options[:base_uri])
      @oauth_token = OAuth2::AccessToken.from_hash(
                      oauth_client,
                      {access_token: @access_token,
                       refresh_token: @refresh_token,
                       created_at: @created_at,
                       expires_in: @expires_in,
                       expires_at: @expires_at})
      @objects = {}
    end

    def find_one(type, id, facility_id: nil, include: nil, force: false)
      obj = get_record(type, id)
      if !obj || force
        refresh if @oauth_token.expired?

        url = if facility_id
                "#{@options[:base_uri]}/api/v3/facilities/#{facility_id}/#{type}/#{id}"
              else
                "#{@options[:base_uri]}/api/v3/#{type}/#{id}"
              end
        url = "#{url}?include=#{include}" if include

        response = @oauth_token.get(url)
        obj = process_response(response, type) if response.status == 200
      end
      obj
    end

    def find_all(type, facility_id: nil, include: nil, params: nil)
      records = []
      refresh if @oauth_token.expired?

      url = if facility_id
              "#{@options[:base_uri]}/api/v3/facilities/#{facility_id}/#{type}"
            else
              "#{@options[:base_uri]}/api/v3/#{type}"
            end
      url = "#{url}?include=#{include}" if include
      url = "#{url}?params=#{params}" if params

      response = @oauth_token.get(url)
      if response.status == 200
        records = process_array(response, type, records)
      end
      records
    end

    def store_record(type, id, data)
      @objects[type] ||= {}
      @objects[type][id.to_i] = ArtemisApi::Model.instance_for(type, data, self)
    end

    def get_record(type, id)
      @objects[type]&.[](id.to_i)
    end

    def refresh
      @oauth_token = @oauth_token.refresh!
    end

    private

    def process_response(response, type)
      json = JSON.parse(response.body)
      obj = store_record(type, json['data']['id'].to_i, json['data'])
      process_included_objects(json['included']) if json['included']

      obj
    end

    def process_array(response, type, records)
      json = JSON.parse(response.body)
      json['data'].each do |obj|
        record = store_record(type, obj['id'], obj)
        records << record
      end
      process_included_objects(json['included']) if json['included']

      records
    end

    def process_included_objects(included_array)
      included_array.each do |included_obj|
        store_record(included_obj['type'], included_obj['id'], included_obj)
      end
    end
  end
end
