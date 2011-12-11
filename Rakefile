require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'csv'

desc "Import stop times"
task :import_stop_times do
  redis = Redis.new
  CSV.open('google_transit/stop_times.txt') do |csv|
    print 'importing stop times'
    csv.each do |parts|
      print '.'
      redis.set "stoptime-#{parts[3]}-#{parts[0]}", parts[1]
    end
    print "\n"
  end
end
