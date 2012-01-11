require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'base64'
require './models'

TZ = TZInfo::Timezone.get('America/Los_Angeles')

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def format_time(time)
    TZ.utc_to_local(time).strftime('%-I:%M %P')
  end
end

config = {
  name: 'Bob',
  routes: [
    {name: 'Home to Work', options: [
      {tag: '12', start: '4966', stop: '4672', add: 9},
      {tag: '10', start: '3010', stop: '6191', add: 9},
      {tag: '9', start: '5657', stop: '6029', add: 3},
      {tag: '9L', start: '5657', stop: '6027', add: 4}
    ]},
    {name: 'Work to Home', options: [
      {tag: '12', start: '4671', stop: '4657', add: 9},
      {tag: '10', start: '6189', stop: '3009', add: 5},
      {tag: '9', start: '6028', stop: '7264', add: 11},
      {tag: '9L', start: '6026', stop: '7264', add: 11}
    ]},
    {name: 'Late Night Hacking', options: [
      {tag: '14', start: '5528', stop: '5552', add: 15}
    ]},
  ]
}

get '/' do
  @config = Muniup::Config.new(config)
  erb :index, :layout => !request.xhr?
end

get %r{^/(\d+)$} do |routeIdx|
  @route = Muniup::Config.new(config).routes[routeIdx.to_i]
  @route.fetch_predictions!
  erb :show, :layout => !request.xhr?
end

get %r{^/(\d+)/(\d+)/(\d+)$} do |routeIdx, optionIdx, vehicle|
  @route = Muniup::Config.new(config).routes[routeIdx.to_i]
  @option = @route.options[optionIdx.to_i]
  @option.fetch_predictions!
  @prediction = @option.predictions.find{|p| p[:vehicle] == vehicle}
  @coords = Muniup::Predictor.get_vehicle_coords(@option.tag, vehicle)
  erb :trip, :layout => !request.xhr?
end
