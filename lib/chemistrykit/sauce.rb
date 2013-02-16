module ChemistryKit
  module Sauce

    def set_sauce_keys
      self.magic_keys = [
      :caller,
      :description,
      :description_args,
      :example_group,
      :example_group_block,
      :execution_result,
      :file_path,
      :full_description,
      :line_number,
      :location
      ]
    end

    def sauce_executor
      "http://#{SAUCE_CONFIG['username']}:#{SAUCE_CONFIG['key']}@ondemand.saucelabs.com:80/wd/hub"
    end

    def sauce_api_url
      "http://#{SAUCE_CONFIG['username']}:#{SAUCE_CONFIG['key']}@saucelabs.com:80/rest/v1/#{SAUCE_CONFIG['username']}/jobs/#{@session_id}"
    end

    def setup_data_for_sauce
      self.example_tags = self.example.metadata.collect do |k, v|
        if not magic_keys.include?(k)
          if v.to_s == 'true'
            k
          else
            "#{k}:#{v}"
          end
        end
      end
      example_tags.compact!
    end

    def create_payload
      self.payload = {
        :tags => example_tags,
        :name => example.metadata[:full_description],
        :passed => example.exception ? false : true
      }
    end

    def post_to_sauce
      RestClient.put sauce_api_url, payload.to_json, {:content_type => :json}
    end

  end
end
