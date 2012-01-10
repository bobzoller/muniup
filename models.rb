require 'ostruct'
require 'open-uri'
require 'cgi'

module Muniup
  class Config < OpenStruct
    def routes
      @routes ||= super.map{|r| Route.new(r)}
    end
  end

  class Route < OpenStruct
    def options
      @options ||= super.map{|o| Option.new(o)}
    end

    def upcoming_predictions
      self.predictions.select{|p| p[:departs] && p[:arrives]}
    end

    def predictions
      self.options.map{|o| o.predictions}.flatten.sort_by{|p| p[:finish]}
    end

    def fetch_predictions!
      tuples = self.options.map{|o| o.tuple}
      Predictor.new(tuples).fetch_predictions.each_with_index do |p, idx|
        self.options[idx].predictions = p
      end
    end
  end

  class Option < OpenStruct

    def tuple
      [self.tag, self.start, self.stop]
    end

    def predictions=(new_predictions)
      new_predictions.each do |p|
        if p[:arrives]
          p[:finish] = Time.now.utc + (p[:arrives] * 60) + (self.add * 60)
        end
      end
      super(new_predictions)
    end

    def fetch_predictions!
      self.predictions = Predictor.new([self.tuple]).fetch_predictions[0]
    end

    def get_vehicle_coords(vehicle_id)
      {lat: 30.0, lon: -46.0}
    end
  end

  class Predictor

    def self.get_vehicle_coords(route, vehicle)
      url = "http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni&r=#{CGI.escape(route)}"
      doc = Nokogiri::XML(open(url))
      vehicle = doc.at_xpath("//vehicle[@id='#{vehicle}']")
      vehicle ? {lat: vehicle['lat'], lon: vehicle['lon']} : nil
    end

    # tuples is an array of tuples: [route_tag, start_stop_id, end_stop_id]
    def initialize(tuples)
      @tuples = tuples
    end

    def url
      url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni'
      stop_params = @tuples.map{|t| ["#{t[0]}|null|#{t[1]}", "#{t[0]}|null|#{t[2]}"]}.flatten.uniq
      url << '&' + stop_params.map{|stop_param| "stops=#{CGI.escape(stop_param)}"}.join('&')
      url
    end

    def fetch_predictions
      start_tags = @tuples.map{|t| t[1]}.uniq
      stop_tags = @tuples.map{|t| t[2]}.uniq
      predictions = []
      doc = Nokogiri::XML(open(self.url))
      @tuples.each do |route_tag, start_stop_id, end_stop_id|
        trips = {}

        # capture the starting stop prediction
        group = doc.at_xpath("//predictions[@routeTag='#{route_tag}' and @stopTag='#{start_stop_id}']")
        if group.nil?
          predictions << []
          next
        end
        group.xpath('.//prediction').each do |p|
          trips[p['tripTag']] ||= {
            title: "#{group['routeTitle']} @ #{group['stopTitle']}",
            vehicle: p['vehicle'],
            departs: p['minutes'].to_i,
            arrives: nil
          }
        end

        # captures the ending stop prediction
        group = doc.at_xpath("//predictions[@routeTag='#{route_tag}' and @stopTag='#{end_stop_id}']")
        if group.nil?
          predictions << []
          next
        end
        group.xpath('.//prediction').each do |p|
          trips[p['tripTag']] ||= {
            title: "#{group['routeTitle']} @ #{group['stopTitle']}",
            vehicle: p['vehicle'],
            departs: nil
          }
          trips[p['tripTag']][:arrives] = p['minutes'].to_i
        end

        # selects predictions that have at least an arrival time and sorts by departure time.
        predictions << trips.values.
          select{|t| t[:arrives]}.
          sort_by{|t| t[:departs] || -1}
      end
      predictions
    end
  end

end
