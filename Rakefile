require 'bundler'
Bundler.require
require 'csv'
require 'pp'
require 'logger'
require 'yaml'

require_relative 'lib/npi_registry'
require_relative 'lib/report'

APP_ROOT = Pathname.new('.').realpath
CONFIG_DIR = APP_ROOT + 'config'
INPUT_DIR = APP_ROOT + 'input'
LOG_DIR = APP_ROOT + 'log'
TMP_DIR = APP_ROOT + 'tmp'
CACHED_DIR = TMP_DIR + 'cached'

directory INPUT_DIR
directory TMP_DIR
directory CACHED_DIR
directory LOG_DIR
directory CONFIG_DIR

NPI_LIST = INPUT_DIR + 'npi_list.txt'
NUCC_URI = 'http://nucc.org/images/stories/CSV/nucc_taxonomy_191.csv'
TAXONOMY_DATA = CONFIG_DIR + 'taxonomy.yml'

desc 'initialize the project'
task :init => [NPI_LIST, CACHED_DIR, LOG_DIR, 'download:taxonomy', TAXONOMY_DATA] do
  puts "Check http://nucc.org/images/stories/CSV and see if #{Pathname(NUCC_URI).basename} is still current."
end

desc 'report'
task :report => [NPI_LIST, CACHED_DIR, LOG_DIR, TAXONOMY_DATA] do
  logger = Logger.new(LOG_DIR + 'npi_registry.log')
  npi_list = IO.readlines(NPI_LIST).map(&:chomp)
  providers = npi_list.map { |npi| NPIRegistry.provider(npi: npi, cached_dir: CACHED_DIR, logger: logger) }
  puts ['Providers:', providers.size].join(' ')
  taxonomy_data = YAML.load_file(TAXONOMY_DATA)
  report = Report.new(providers: providers, taxonomy_data: taxonomy_data, primary_only: false, logger: logger)
  File.open(TMP_DIR + "taxonomy_#{Time.now.strftime('%Y%m%d')}.txt", 'w') do |f|
    f.puts Terminal::Table.new(rows: report.rows, headings: report.headings)
  end
end