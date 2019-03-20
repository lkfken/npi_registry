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
NUCC_URI = 'http://nucc.org/images/stories/CSV/nucc_taxonomy_190.csv'
TAXONOMY_DATA = CONFIG_DIR + 'taxonomy.yml'


file NPI_LIST => INPUT_DIR do
  RakeFileUtils.touch NPI_LIST
end

file TAXONOMY_DATA => CONFIG_DIR do
  CSV.open(TMP_DIR + 'nucc_taxonomy_190.csv', :headers => true) do |csv|
    data = csv.inject(Hash.new) do |h, row|
      code, grouping, classification, specialization, definition, notes = row['Code'], row['Grouping'], row['Classification'], row['Specialization'], row['Definition'], row['Notes']
      raise "#{code} is already defined" unless h[code].nil?
      h[code] = {grouping: grouping, classification: classification, specialization: specialization, definition: definition, notes: notes}
      h
    end
    File.open(TAXONOMY_DATA, 'w') {|f| f.puts data.to_yaml}
  end
end

namespace :download do
  desc 'download provider (NPI) registry records'
  task :provider => [NPI_LIST, CACHED_DIR, LOG_DIR] do
    logger = Logger.new(LOG_DIR + 'npi_registry.log')
    npi_list = IO.readlines(NPI_LIST).map(&:chomp).first(1)
    npi_list.each {|npi| NPIRegistry.provider(npi: npi, cached_dir: CACHED_DIR, logger: logger)}
  end

  desc 'download health care provider taxonomy code set'
  task :taxonomy => TMP_DIR do
    uri = URI(NUCC_URI)
    resource = HTTP.get(uri)
    file = Pathname(uri.path)
    File.open(TMP_DIR + file.basename, 'w') {|f| f.puts resource}
  end
end

desc 'report'
task :report => [NPI_LIST, CACHED_DIR, LOG_DIR, TAXONOMY_DATA] do
  logger = Logger.new(LOG_DIR + 'npi_registry.log')
  npi_list = IO.readlines(NPI_LIST).map(&:chomp).first(10)
  providers = npi_list.map {|npi| NPIRegistry.provider(npi: npi, cached_dir: CACHED_DIR, logger: logger)}
  taxonomy_data = YAML.load_file(TAXONOMY_DATA)
  report = Report.new(providers: providers, taxonomy_data: taxonomy_data, primary_only: true)
  puts Terminal::Table.new(rows: report.rows, headings: report.headings)
end