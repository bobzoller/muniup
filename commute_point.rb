require 'open-uri'

class CommutePoint
  def self.fetch(url)
    data = []
    doc = Nokogiri::HTML(open(url))
    doc.css('predictions').each do |predictions|
      entry = {route: predictions['routetitle'], tag: predictions['routetag'], stop: predictions['stoptitle'], times: []}
      predictions.css('prediction').each do |prediction|
        entry[:times] << prediction['minutes'].to_i
      end
      data << entry
    end
    data
  end
end
