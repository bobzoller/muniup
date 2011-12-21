require 'open-uri'
require 'cgi'

module Muniup
  class Route

    def self.getFeedUrl(route)
      uri = URI.parse('http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni')
      stop_params = route[:options].map{|o| ["#{o[:tag]}|null|#{o[:start]}", "#{o[:tag]}|null|#{o[:stop]}"]}.flatten.uniq
      uri.query += '&' + stop_params.map{|stop_param| "stops=#{CGI.escape(stop_param)}"}.join('&')
      puts uri.to_s
      uri.to_s
    end

    def self.fetch(route)
      start_tags = route[:options].map{|o| o[:start]}.uniq
      stop_tags = route[:options].map{|o| o[:stop]}.uniq
      data = {}
      doc = Nokogiri::HTML(open(getFeedUrl(route)))
      doc.css('predictions').each do |predictions|
        predictions.css('prediction').each do |prediction|
          data[prediction['triptag']] ||= {route: predictions['routetitle'], tag: predictions['routetag'], stop: predictions['stoptitle'], times: {}}
          if start_tags.include? predictions['stoptag']
            data[prediction['triptag']][:times][:start] = prediction['minutes'].to_i
          elsif stop_tags.include? predictions['stoptag']
            data[prediction['triptag']][:times][:stop] = prediction['minutes'].to_i
            data[prediction['triptag']][:times][:final] = Time.now.utc + (prediction['minutes'].to_i * 60) + (route[:options].find{|r| r[:tag] == predictions['routetag']}[:add] * 60)
          end
        end
      end
      data.values.select{|d| d[:times][:start] && d[:times][:stop]}.sort_by{|d| d[:times][:final]}
    end

  end
end
