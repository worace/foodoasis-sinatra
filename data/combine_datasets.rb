require 'csv'
require 'json'
require 'set'

files = Dir.glob('./data/*.csv')

data = files.map do |filename|
  key = filename.split('/').last.gsub(/\.csv$/,'')
  {key => CSV.open(filename, headers: true).map(&:to_h)}
end.reduce(&:merge)

keysets = data.values.map(&:first).map(&:keys)

common_keys = keysets.map { |ks| Set.new(ks) }.reduce(&:intersection).to_a

def slice(hash, keys)
  hash.select { |k,v| keys.include?(k) }.to_h
end

combined = data.flat_map do |location_type, rows|
  rows.map do |r|
    slice(r, common_keys).merge({"location_type" => location_type,
                                 "point" => nil})
  end.select do |r|
    r['name'] && r['latitude'] && r['longitude']
  end
end

common_keys = ["id"] + common_keys

CSV do |csv|
  csv << common_keys
  combined.each do |row|
    csv << row.values
  end
end
