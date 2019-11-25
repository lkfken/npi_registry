namespace :download do
  desc 'download provider (NPI) registry records'
  task :provider => [NPI_LIST, CACHED_DIR, LOG_DIR] do
    logger = Logger.new(LOG_DIR + 'npi_registry.log')
    npi_list = IO.readlines(NPI_LIST).map(&:chomp).first(1)
    npi_list.each { |npi| NPIRegistry.provider(npi: npi, cached_dir: CACHED_DIR, logger: logger) }
  end

  desc 'download health care provider taxonomy code set'
  task :taxonomy => TMP_DIR do
    uri = URI(NUCC_URI)
    resource = HTTP.get(uri)
    file = Pathname(uri.path)
    File.open(TMP_DIR + file.basename, 'w') { |f| f.puts resource }
  end
end
