file NPI_LIST => INPUT_DIR do
  RakeFileUtils.touch NPI_LIST
end

file TAXONOMY_DATA => [CONFIG_DIR] do
  CSV.open(TMP_DIR + Pathname(NUCC_URI).basename, :headers => true) do |csv|
    data = csv.inject(Hash.new) do |h, row|
      code, grouping, classification, specialization, definition, notes = row['Code'], row['Grouping'], row['Classification'], row['Specialization'], row['Definition'], row['Notes']
      raise "#{code} is already defined" unless h[code].nil?
      h[code] = {grouping: grouping, classification: classification, specialization: specialization, definition: definition, notes: notes}
      h
    end
    File.open(TAXONOMY_DATA, 'w') { |f| f.puts data.to_yaml }
  end
end
