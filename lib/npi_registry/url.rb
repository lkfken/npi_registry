module NPIRegistry
  class URL
    attr_reader :uri, :enumeration_type, :limit, :npi

    def initialize(npi:, uri: 'https://npiregistry.cms.hhs.gov/api/?version=2.0', enumeration_type: 'NPI-1', limit: 10)
      @npi = npi
      @uri = uri
      @enumeration_type = enumeration_type
      @limit = limit
    end

    def get
      raise "NPI `#{npi}' is not a valid NPI" if npi.match(/\A\d{10}\z/).nil?
      [uri, "number=#{npi}", "enumeration_type=#{enumeration_type}", "limit=#{limit}"].join('&')
    end
  end
end