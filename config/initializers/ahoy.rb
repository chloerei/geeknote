class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = true

Ahoy.server_side_visits = :when_needed

Ahoy.token_generator = -> { SecureRandom.uuid_v7 }

Ahoy.track_bots = Rails.env.test?

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
