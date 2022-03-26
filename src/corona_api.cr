require "json"

# TODO: Write documentation for `CoronaApi`
module CoronaApi
  VERSION = "0.1.2"

  struct Coordinates
    include JSON::Serializable

    getter latitude : Float64
    getter longitude : Float64
  end

  struct Today
    include JSON::Serializable

    getter deaths : Int32?
    getter confirmed : Int32?
  end

  struct Calculated
    include JSON::Serializable

    getter death_rate : Float64?
    getter recovery_rate : Float64?
    getter recovered_vs_death_ratio : Float64?
    getter cases_per_million_population : Float64?
  end

  struct LatestData
    include JSON::Serializable

    getter deaths : Int32?
    getter confirmed : Int32?
    getter recovered : Int32?
    getter critical : Int32?
    getter calculated : Calculated
  end

  struct TimelineItem
    include JSON::Serializable

    @[JSON::Field(converter: Time::Format.new("%Y-%m-%d"))]
    getter date : Time
    getter deaths : Int32?
    getter confirmed : Int32?
    getter recovered : Int32?
    getter new_deaths : Int32?
    getter new_confirmed : Int32?
    getter new_recovered : Int32?
    getter active : Int32?

    def death_rate : Float64?
      if !@deaths.nil? && !@confirmed.nil?
        return 100 * @deaths.not_nil! / @confirmed.not_nil!
      else
        return nil
      end
    end
  end

  struct Data
    include JSON::Serializable

    getter coordinates : Coordinates
    getter name : String
    getter code : String
    getter population : Int32
    getter updated_at : Time
    getter today : Today
    getter latest_data : LatestData

    getter timeline : Array(TimelineItem)
  end

  def self.get_data(country_code : String) : Data
    data = HTTP::Client.get("https://corona-api.com/countries/#{country_code}")

    Data.from_json(data.body, root: "data")
  end
end
