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

