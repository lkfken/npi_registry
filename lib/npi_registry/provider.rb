module NPIRegistry
  class Provider
    attr_reader :json

    def initialize(json:)
      @json = json
    end

    def first_names
      basic.map {|result| result.fetch('first_name')}
    end

    def last_names
      basic.map {|result| result.fetch('last_name')}
    end

    def middle_names
      basic.map {|result| result.fetch('middle_name', nil)}
    end

    def name_prefixes
      basic.map {|result| result.fetch('name_prefix', nil)}
    end

    def credentials
      basic.map {|result| result.fetch('credential')}
    end

    def basic
      results.map {|result| result.fetch('basic')}
    end

    def results
      (0..result_count - 1).map {|index| json.fetch('results')[index]}
    end

    def npi
      all_npi = results.map {|result| result.fetch('number')}
      only_1_record? ? all_npi.first : all_npi
    end

    def taxonomies
      @taxonomies ||= begin
        records = results.flat_map {|result| result.fetch('taxonomies')}
        records.map {|t| OpenStruct.new(code: t['code'], desc: t['desc'], primary: t['primary'], state: t['state'], license: t['license'])}
      end
    end

    def name
      if only_1_record?
        @name ||= [name_prefixes.first, first_names.first, middle_names.first, last_names.first].compact.join(' ')
      end
    end

    private

    def valid?
      result_count > 0
    end

    def only_1_record?
      result_count == 1
    end

    def result_count
      @result_count ||= json.fetch('result_count', 0)
    end
  end
end