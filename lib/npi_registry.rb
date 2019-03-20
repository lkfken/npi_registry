require_relative 'npi_registry/resource'
require_relative 'npi_registry/provider'
require 'multi_json'

module NPIRegistry
  def self.provider(npi:, cached_dir:, logger:)
    resource = NPIRegistry::Resource.new(npi: npi, cached_dir: cached_dir, logger: logger)
    json = MultiJson.load(resource.get)
    NPIRegistry::Provider.new(json: json)
  end
end