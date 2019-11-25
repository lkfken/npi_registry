require_relative 'npi_registry/resource'
require_relative 'npi_registry/provider'
require 'multi_json'

module NPIRegistry
  def self.provider(npi:, cached_dir:, logger:)
    resource = NPIRegistry::Resource.new(npi: npi, cached_dir: cached_dir, logger: logger)
    begin
      json = MultiJson.load(resource.get)
      NPIRegistry::Provider.new(npi: npi, json: json)
    rescue MultiJson::ParseError => ex
      warn [npi, ex.message].join(' ')
    end
  end
end