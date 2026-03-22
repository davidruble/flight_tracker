# FlightTracker

`flight_tracker` is an event-sourced [ADS-B](https://www.faa.gov/about/office_org/headquarters_offices/avs/offices/afx/afs/afs400/afs410/ads-b) flight tracking system written in Elixir. It was made just for fun because 1. I like aviation, 2. I like Elixir, and 3. I like event sourcing. It's probably overkill for its purpose but who cares!

The data is ingested in [BaseStation SBS format](http://woodair.net/sbs/article/barebones42_socket_data.htm) from either a csv file or [dump1090](https://github.com/antirez/dump1090) hooked up to an ADS-B receiver like an [RTL-SDR](https://www.rtl-sdr.com/about-rtl-sdr/).

Inspired by an exercise in the book _Real-World Event Sourcing_ published by The Pragmatic Programmers.

## Development

- Intall Elixir >= 1.19
- After cloning run `git config --local core.hooksPath .githooks/` to setup git hooks
- Run `mix do deps.get + deps.compile`
- I recommend installing VS Code with the following plugins and enable Format on Save:
  - pantajoe.vscode-elixir-credo
  - jakebecker.elixir-ls

## Running The Application

The application supports the following command line arguments:
  - `--filename my_file.csv` or `-f my_file.csv` 
    - `my_file.csv` needs to reside in `priv/data`
    - If this is provided, the application will read from the file and NOT from a live source

### Running From A File

To run locally: 
- `elixir -S mix run --no-halt -- --filename basestation.csv`.

To run in an interactive console where you can check aggregate or DB state:
- `iex -S mix run -- -f basestation.csv`

### Running With Live Data

TODO: Describe how to run dump1090 alongside the application.

### Sample interactive run using the file `bigchungus.csv`

```elixir
iex -S mix run -- -f bigchungus.csv

#
# ... application reads file and processes commands ...
#

Mix.Task.rerun("get_agg_state", ["400159"])

# Something like this will be printed to the console
FlightTracker.App.Aggregates.Aircraft{
  icao_address: "400159",
  updated_ts: ~U[2018-04-03 19:02:40.178Z],
  squawk_code: 1017,
  callsign: "SDM6244",
  flight_id: "1",
  aircraft_id: "1",
  altitude: 2650,
  latitude: 59.71545,
  longitude: 30.63446,
  ground_speed: 198.0,
  track: 314.0,
  vertical_rate: -64,
  is_on_ground: false,
  is_emergency: false
}
```

## Flight Plan

- [x] Read static data from a csv file
- [ ] Read real data from dump1090
- [ ] Create a scheduled task that cleans out old data so it doesn't blow up in size
- [ ] Display flight data in a UI leveraging Phoenix LiveView

## If We Have Enough Fuel

- [ ] Get a wider range of data from an ADS-B data exchange like [ADSBHub](https://www.adsbhub.org/)
- [ ] Leverage a more robust datastore than just `:ets`, probably something like postgres
- [ ] Host the project publicly, possibly with something like [fly.io](https://fly.io/docs/elixir/getting-started/existing/)

## Legal-ish Note

This project was made just for fun with publicly available data and should not be used for commercial purposes or by stalkers.
