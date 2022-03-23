require "minitest/autorun"

require "/../src/corona_api"

class CoronaApiTest < Minitest::Test
  def test_parses_coordinates
    json = %({"latitude":22.25,"longitude":114.1667})

    coords = CoronaApi::Coordinates.from_json(json)

    assert_equal 22.25, coords.latitude
    assert_equal 114.1667, coords.longitude
  end

  def test_parses_latest_data
    json = %({"deaths":213,"confirmed":12177,"recovered":11888,"critical":76,"calculated":{"death_rate":1.74919931017492,"recovery_rate":97.62667323642933,"recovered_vs_death_ratio":null,"cases_per_million_population":0}})

    latest = CoronaApi::LatestData.from_json(json)

    assert_equal 213, latest.deaths
    assert_equal 12177, latest.confirmed
    assert_equal 11888, latest.recovered
    assert_equal 76, latest.critical
    assert_equal 1.74919931017492, latest.calculated.death_rate
    assert_equal 97.62667323642933, latest.calculated.recovery_rate
    assert_equal nil, latest.calculated.recovered_vs_death_ratio
    assert_equal 0, latest.calculated.cases_per_million_population
  end

  def test_parses_data
    json = %({"coordinates":{"latitude":22.25,"longitude":114.1667},"name":"Hong Kong","code":"HK","population":6898686,"updated_at":"2022-03-23T21:43:20.111Z","today":{"deaths":0,"confirmed":0},"latest_data":{"deaths":213,"confirmed":12177,"recovered":11888,"critical":76,"calculated":{"death_rate":1.74919931017492,"recovery_rate":97.62667323642933,"recovered_vs_death_ratio":null,"cases_per_million_population":0}},"timeline":[]})

    data = CoronaApi::Data.from_json(json)

    assert_equal 22.25, data.coordinates.latitude
    assert_equal 114.1667, data.coordinates.longitude

    assert_equal "Hong Kong", data.name
    assert_equal "HK", data.code
    assert_equal 6898686, data.population
    assert_equal Time.parse("2022-03-23T21:43:20.111Z", "%Y-%m-%dT%H:%M:%S.%3NZ", Time::Location::UTC), data.updated_at
  end
end
