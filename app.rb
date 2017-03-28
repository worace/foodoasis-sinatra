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

  def nearby_locations(lat, lon, radius = 4500)
    lat = lat.to_f
    lon = lon.to_f
    radius = radius.to_i
    query = "SELECT * FROM locations WHERE ST_DWithin(point, ST_Point(#{lon}::numeric, #{lat}::numeric), #{radius}::numeric);"
    DB.exec(query)
  end

  get '/' do
    redirect "/nearby?latitude=34.0522&longitude=-118.2437"
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
end
