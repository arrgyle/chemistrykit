# Encoding: utf-8

require 'uri'
module ChemistryKit
  module Config
    class BasicAuth

      attr_accessor :username, :password, :base_url, :http_path, :https_path
      attr_reader :base_uri

      def initialize(opts)
        opts.each do |key, value|
          begin
            send("#{key}=", value)
          rescue NoMethodError
            raise ArgumentError.new "The config key: \"#{key}\" is unknown!"
          end
        end
        @base_uri = URI.parse(base_url) unless base_url.nil?
      end

      def http?
        !!http_path
      end

      def https?
        !!https_path
      end

      def appended_path(config_path)
        ret = if config_path.nil?
           base_uri.path
        else
          (base_uri.path.split('/') + config_path.split('/')).reject(&:empty?).join('/')
        end
        ret.empty? ? '' : "/#{ret}"
      end

      def http_url
        "http://#{username}:#{password}@#{base_uri.host}" + appended_path(http_path)
      end

      def https_url
        "https://#{username}:#{password}@#{base_uri.host}" + appended_path(https_path)
      end

    end
  end
end
