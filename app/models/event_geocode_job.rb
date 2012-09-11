class EventGeocodeJob < Struct.new(:event_id) 
	def perform
		Event.find(event_id).tap do |e|
			e.geocode
			e.reverse_geocode
			e.save
		end
	end
end