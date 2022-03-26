require "minitest/autorun"
require "webmock"

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

  def test_parses_timeline_item
    json = %({"updated_at":"2022-03-25T04:20:46.000Z","date":"2022-03-25","deaths":37406,"confirmed":3436460,"recovered":0,"new_confirmed":7053,"new_recovered":0,"new_deaths":75,"active":3399054})

    data = CoronaApi::TimelineItem.from_json(json)

    assert_equal Time.utc(2022, 3, 25), data.date
    assert_equal 37406, data.deaths
    assert_equal 3436460, data.confirmed
    assert_equal 0, data.recovered
    assert_equal 7053, data.new_confirmed
    assert_equal 0, data.new_recovered
    assert_equal 75, data.new_deaths
    assert_equal 3399054, data.active

    assert_equal "1.09", data.death_rate.not_nil!.format(decimal_places: 2)
  end

  def test_gets_data
    WebMock.stub(:get, "https://corona-api.com/countries/KR").to_return(status: 200, body: File.read("test/files/kr.json"))

    data = CoronaApi.get_data("KR")

    assert_equal "S. Korea", data.name
    assert_equal "KR", data.code
    assert_equal 48422644, data.population
    assert_equal Time.parse("2022-03-23T22:27:16.214Z", "%Y-%m-%dT%H:%M:%S.%3NZ", Time::Location::UTC), data.updated_at

    assert_equal 7, data.today.deaths
    assert_equal 3273, data.today.confirmed

    assert_equal 0.8180240078819847, data.latest_data.calculated.death_rate

    first_timeline = data.timeline[0]

    assert_equal Time.utc(2022, 3, 23), first_timeline.date
    assert_equal 490707, first_timeline.new_confirmed
  end
end
