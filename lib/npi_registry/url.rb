# https://npiregistry.cms.hhs.gov/registry/help-api
module NPIRegistry
  class URL
    attr_reader :uri, :enumeration_type, :limit, :npi
    def initialize(npi:, uri: 'https://npiregistry.cms.hhs.gov/api/?version=2.0', enumeration_type: nil, limit: 10)
      @npi = npi
      @uri = uri
      @enumeration_type = enumeration_type # either "NPI-1" or "NPI-2"
      @limit = limit
    end

    def get
      raise "NPI `#{npi}' is not a valid NPI" if npi.match(/\A\d{10}\z/).nil?
      # [uri, "number=#{npi}", "enumeration_type=#{enumeration_type}", "limit=#{limit}"].join('&')
      params = [uri, "number=#{npi}", "limit=#{limit}"]
      params << "enumeration_type=#{enumeration_type}" if enumeration_type
      params.join('&')
    end
  end
end