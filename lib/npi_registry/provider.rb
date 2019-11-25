module NPIRegistry
  class Provider
    attr_reader :json, :npi

    def initialize(npi:, json:)
      @npi = npi
      @json = json
    end

    def to_a
      [npi, enumeration_type, name, taxonomies]
    end

    def type
      case enumeration_type
      when 'NPI-1'
        'IND'
      when 'NPI-2'
        'ORG'
      end
    end

    def enumeration_type
      @enumeration_type ||= begin
        result = results.map { |result| result.fetch('enumeration_type') }.uniq
        raise "Multiple enumeration type with the given NPI #{npi}" if result.size != 1
        result.first
      end
    end

    def not_found?
      taxonomies.empty?
    end

    def first_names
      basic.map { |result| result.fetch('first_name') }
    end

    def last_names
      basic.map { |result| result.fetch('last_name') }
    end

    def middle_names
      basic.map { |result| result.fetch('middle_name', nil) }
    end

    def name_prefixes
      basic.map { |result| result.fetch('name_prefix', nil) }
    end

    def credentials
      basic.map { |result| result.fetch('credential') }
    end

    def basic
      results.map { |result| result.fetch('basic') }
    end

    def results
      (0..result_count - 1).map { |index| json.fetch('results')[index] }
    end

    def record_npi
      all_npi = results.map { |result| result.fetch('number') }
      value = only_1_record? ? all_npi.first : all_npi
      raise "Given NPI #{npi} != Record NPI #{value}" if npi != value
      value
    end

    def taxonomies
      @taxonomies ||= begin
        records = results.flat_map { |result| result.fetch('taxonomies') }
        records.map { |t| OpenStruct.new(code: t['code'], desc: t['desc'], primary: t['primary'], state: t['state'], license: t['license']) }
      end
    end

    def name
      @name ||= begin
        case enumeration_type
        when 'NPI-1'
          provider_name
        when 'NPI-2'
          organization_name
        else
          raise
        end
      end
    end

    def provider_name
      names = (0..(result_count - 1)).map do |index|
        [name_prefixes[index], first_names[index], middle_names[index], last_names[index]].compact.join(' ')
      end
      only_1_record? ? names.first : names
    end

    def organization_name
      names = basic.map { |result| result.fetch('organization_name') }
      only_1_record? ? names.first : names
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