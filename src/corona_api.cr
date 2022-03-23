require "json"

# TODO: Write documentation for `CoronaApi`
module CoronaApi
  VERSION = "0.1.0"

  struct Coordinates
    include JSON::Serializable

    getter latitude : Float64
    getter longitude : Float64
  end

  struct Today
    include JSON::Serializable

    getter deaths : Int32?
    getter cases : Int32?
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

  struct Data
    include JSON::Serializable

    getter coordinates : Coordinates
    getter name : String
    getter code : String
    getter population : Int32
    getter updated_at : Time
  end
end
