require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'
require 'pg'

DB_URL = ENV['HEROKU_POSTGRESQL_BLACK_URL'] || "postgres://localhost/foodoasis_gis"
DB = PG.connect(DB_URL)

class FoodOasis < Sinatra::Base
  register Sinatra::CrossOrigin

  configure do
    enable :cross_origin
  end

  def query(lat, lon, types, radius)
    <<~HEREDOC
      SELECT locations.*, ST_Distance(point, ST_Point(#{lon}::numeric, #{lat}::numeric)) / 1609.34 as distance
      FROM locations
      WHERE ST_DWithin(point, ST_Point(#{lon}::numeric, #{lat}::numeric), #{radius}::numeric)
      AND location_type in (#{types})
      ORDER BY distance asc;
    HEREDOC
  end

  def nearby_locations(lat, lon, location_types, radius = 3500)
    lat = lat.to_f
    lon = lon.to_f
    radius = radius.to_i
    types = location_types.map { |t| "'#{t}'" }.join(",")
    q = query(lat, lon, types, radius)
    puts "exec q:"
    puts q
    DB.exec(q)
  end

  get '/' do
    redirect "/nearby?latitude=34.0522&longitude=-118.2437"
  end

  get '/health' do
    content_type :json
    {status: "OK"}.to_json
  end

  def accepted_types
    ['supermarket', 'food_pantry', 'farmers_market', 'community_garden']
  end

  get '/nearby' do
    content_type :json
    location_types = accepted_types.select do |t|
      # Types are "on" by default, so we include the
      # location type if it is not present in the params map
      # or it is present with a falsey value
      !params.has_key?(t) || params[t] == "true"
    end
    nearby_locations(params[:latitude],
                     params[:longitude],
                     location_types).to_a.to_json
  end
end
