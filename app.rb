require 'rubygems'
require 'bundler/setup'
Bundler.require

require './route'

TZ = TZInfo::Timezone.get('America/Los_Angeles')

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def format_time(time)
    TZ.utc_to_local(time).strftime('%-I:%-M %P')
  end
end

config = {
  name: 'Bob',
  routes: [
    {name: 'Work to Home', options: [
      {tag: '9', start: '6028', stop: '5685', add: 2},
      {tag: '9L', start: '6026', stop: '5685', add: 2}
    ]},
    {name: 'Home to Work', options: [
      {tag: '9', start: '5639', stop: '6027', add: 5},
      {tag: '9L', start: '5639', stop: '6027', add: 5}
    ]},
  ]
}

get '/' do
  @config = config
  erb :index
end

get %r{/(\d+)} do |idx|
  @route = config[:routes][idx.to_i]
  @data = Muniup::Route.fetch(@route)
  erb :show
end

