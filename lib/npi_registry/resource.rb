require 'http'
require 'logger'
require_relative 'url'

module NPIRegistry
  class Resource
    attr_reader :npi, :cached_dir

    def initialize(npi:, cached_dir: nil, logger: Logger.new($stdout))
      @npi = npi
      @cached_dir = cached_dir
      @url = NPIRegistry::URL.new(npi: npi).get
      @logger = logger
    end

    def get
      @response ||= (caching? ? read_from_cache : read_from_internet)
    end

    private

    def read_from_internet
      HTTP.get(@url)
    end

    def read_from_cache
      if caching? && File.exist?(cached_file = cached_dir + "#{npi}.json")
        IO.read(cached_file)
      else
        @logger.debug "Retrieve and save the NPI (#{npi}) registry record from #{@url}"
        resp = read_from_internet
        File.open(cached_file, 'w') {|f| f.puts resp}
        resp
      end
    end

    def caching?
      !!cached_dir
    end
  end
end
