CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

# Loop over each row and process individual values in place
def process_rows!(rows)
  rows.map! do |row|
    row.map! do |value|
      if value.is_a? String
        # Replace extra whitespaces
        value.strip!
        value.squeeze!(' ')

        # Replace extra pipe delimiters
        value.squeeze!('|')
        value.chomp!('|')
        value = value.sub(/^[|]*/, '')

        # Replace incorrect newlines
        value = value.gsub '<br>', "\n"
        value = value.gsub '\\n', "\n"
        value.squeeze("\n")
      else
        value
      end
    end
  end

  # Remove duplicate rows
  rows.uniq!
end

def write_csv(records, filename)
  FileUtils.mkdir_p './sanitize_out'
  CSV.open("./sanitize_out/descriptions.#{filename}.csv", 'wb') do |f|
    f << records[0].keys
    records.each { |r| f << r.values }
  end
end

def count_legacyids(records)
  legacy_ids = {}
  records.each do |r|
    legacy_ids[r['legacyId']] = 0 if legacy_ids[r['legacyId']].nil?
    legacy_ids[r['legacyId']] += 1
  end

  legacy_ids
end

def find_duplicate_legacy_ids(records, legacy_ids)
  duplicate_keys = legacy_ids.select { |_, v| v > 1 }.keys
  records.select { |r| duplicate_keys.include?(r['legacyId']) }
end

def find_orphaned(records, legacy_ids)
  records.select { |r| !legacy_ids.keys.include?(r['parentId']) && !r['parentId'].nil? }
end

def find_nil_records(records)
  records.select { |r| r['legacyId'].nil? }
end

def find_self_referencing(records)
  records.select { |r| !r['parentId'].nil? && (r['legacyId'] == r['parentId']) }
end

def sort_csv(records, parents = nil, level = 0)
  # if parents is nil, this is the first iteration
  parents = records.select { |r| r['parentId'].nil? } if parents.nil?
  # write_csv(parents, "descriptionlevel-#{level}")

  # figure out if records have parents in parents
  ids = parents.map { |r| r['legacyId'] }
  children = records.select { |r| ids.include?(r['parentId']) }
  return parents if children.count == 0

  records -= children
  parents + sort_csv(records, children, level + 1)
end
