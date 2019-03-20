class Report
  def initialize(providers:, taxonomy_data:)
    @providers = providers
    @taxonomy_data = taxonomy_data
  end

  def rows
    @providers.inject(Array.new) do |a, provider|
      provider.taxonomies.each do |taxonomy|
        a << [provider.npi, provider.name, taxonomy.code, taxonomy.desc, classification(taxonomy.code), specialization(taxonomy.code)]
      end
      a
    end
  end

  def headings
    %w[NPI NAME CODE DESC CLASSIFICATION SPECIALIZATION]
  end

  private

  def classification(code)
    @taxonomy_data[code][:classification]
  end

  def specialization(code)
    @taxonomy_data[code][:specialization]
  end
end