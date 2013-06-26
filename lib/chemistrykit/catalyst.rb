require 'csv'

module ChemistryKit
  class Catalyst
    #this class serves as a standard container for data that can be injected into a formula

    def initialize(data_file)
      @data = {}
      CSV.foreach(data_file) do | row |
        @data[row[0].to_sym] = row[1]
      end
    end

    def method_missing(name)
      validate_key name
      @data[name]
    end

    def get_value_for(key)
      validate_key key
      @data[key.to_sym]
    end

    private

      def validate_key(key)
        unless @data.has_key?(key.to_sym)
          raise "Unknown \"#{key}\""
        end
      end
  end
end
