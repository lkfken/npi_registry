class Report
  attr_reader :logger

  def initialize(providers:, taxonomy_data:, primary_only: false, logger: Logger.new($stderr))
    @providers = providers
    @taxonomy_data = taxonomy_data
    @primary_only = primary_only
    @logger = logger
  end

  def rows
    @providers.inject(Array.new) do |a, provider|
      logger.error "#{provider.npi} not found in the NPI Registry!" if provider.not_found?
      provider.taxonomies.each do |taxonomy|
        if @primary_only && !taxonomy.primary
          logger.debug [provider.npi, provider.name, taxonomy.code, taxonomy.desc, classification(taxonomy.code), specialization(taxonomy.code), taxonomy.primary].join(' ')
          next
        end
        a << [provider.npi, provider.type, provider.name, taxonomy.code, taxonomy.desc, classification(taxonomy.code), specialization(taxonomy.code), taxonomy.primary]
      end
      a
    end
  end

  def headings
    %w[NPI TYPE NAME CODE DESC CLASSIFICATION SPECIALIZATION PRIMARY]
  end

  private

  def classification(code)
    @taxonomy_data[code][:classification]
  end

  def specialization(code)
    @taxonomy_data[code][:specialization]
  end
end