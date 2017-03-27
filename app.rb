require 'sinatra'
require 'json'
require 'pg'

DB = PG.connect(dbname: 'foodoasis_gis')

def nearby_locations(lat, lon, radius = 3500)
  lat = lat.to_f
  lon = lon.to_f
  radius = radius.to_i
  query = "SELECT * FROM locations WHERE ST_DWithin(point, ST_Point(#{lon}::numeric, #{lat}::numeric), #{radius}::numeric);"
  DB.exec(query)
end

get '/health' do
  content_type :json
  {status: "OK"}.to_json
end

get '/nearby' do
  content_type :json
  results = nearby_locations(params[:latitude], params[:longitude])
  results.group_by do |r|
    r['location_type']
  end.to_json
end
