require 'sinatra'
require 'json'

get '/health' do
  content_type :json
  {status: "OK"}.to_json
end

get '/nearby' do
  content_type :json
  puts params
  {lat: params[:latitude], lng: params[:longitude]}.to_json
end
