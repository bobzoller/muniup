require 'rubygems'
require 'bundler/setup'
Bundler.require

require './commute_point'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :index
end

get '/:direction' do
  url = case params['direction']
    when 'in'
      @title = 'Inbound to Downtown'
      'http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&stops=9%7Cnull%7C6028&stops=9L%7Cnull%7C6026'
    when 'out'
      @title = 'Outbound to Visitation Valley'
      'http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&stops=9%7Cnull%7C5639&stops=9L%7Cnull%7C5639'
    else
      raise 'unknown direction'
  end
  @data = CommutePoint.fetch(url)
  erb :show
end
