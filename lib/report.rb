class Report
  def initialize(providers:, taxonomy_data:, primary_only: false)
    @providers = providers
    @taxonomy_data = taxonomy_data
    @primary_only = primary_only
  end

  def rows
    @providers.inject(Array.new) do |a, provider|
      provider.taxonomies.each do |taxonomy|
        next if @primary_only && !taxonomy.primary
        a << [provider.npi, provider.name, taxonomy.code, taxonomy.desc, classification(taxonomy.code), specialization(taxonomy.code), taxonomy.primary]
      end
      a
    end
  end

  def headings
    %w[NPI NAME CODE DESC CLASSIFICATION SPECIALIZATION PRIMARY]
  end

  private

  def classification(code)
    @taxonomy_data[code][:classification]
  end

  def specialization(code)
    @taxonomy_data[code][:specialization]
  end
end