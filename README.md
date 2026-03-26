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

To run in an interactive console where you can check and aircraft's state:
- `iex -S mix run -- -f basestation.csv`
  - Use `Mix.Task.rerun("get_aircraft_state", ["ABCDEF"])` where `ABCDEF` is an ICAO address to see the status of a plane in the file

### Running With Live Data

TODO: Describe how to run dump1090 alongside the application.

### Sample interactive run using the file `bigchungus.csv`


```shell
iex -S mix run -- -f bigchungus.csv

#
# ... application reads file and processes commands ...
#

20:51:48.364 [debug] FlightTracker.App.Aggregates.Aircraft<aircraft-400159@22> executing command: %FlightTracker.App.Commands.UpdateAirbornePosition{icao_address: "400159", altitude: 2650, latitude: 59.70962, longitude: 30.64674, is_emergency: false, generated_ts: 1522782150}

20:51:48.365 [debug] FlightTracker.App.Aggregates.Aircraft<aircraft-400159@23> received events: [%Commanded.EventStore.RecordedEvent{event_id: "659d6122-1aeb-42eb-bb2d-ebc20ac829ee", event_number: 23, stream_id: "aircraft-400159", stream_version: 23, causation_id: "44254b5e-bdee-4ab4-9ccc-7afed4d5473c", correlation_id: "b7f0d29e-4f76-4aae-91ce-6e322edd27e6", event_type: "Elixir.FlightTracker.App.Events.PositionUpdated", data: %FlightTracker.App.Events.PositionUpdated{icao_address: "400159", altitude: 2650, latitude: 59.70962, longitude: 30.64674, is_on_ground: false, generated_ts: 1522782150}, created_at: ~U[2026-03-26 01:51:48.365000Z], metadata: %{}}]

20:51:48.365 [debug] FlightTracker.App.Projectors.Aircraft received events: [%Commanded.EventStore.RecordedEvent{event_id: "659d6122-1aeb-42eb-bb2d-ebc20ac829ee", event_number: 184, stream_id: "aircraft-400159", stream_version: 23, causation_id: "44254b5e-bdee-4ab4-9ccc-7afed4d5473c", correlation_id: "b7f0d29e-4f76-4aae-91ce-6e322edd27e6", event_type: "Elixir.FlightTracker.App.Events.PositionUpdated", data: %FlightTracker.App.Events.PositionUpdated{icao_address: "400159", altitude: 2650, latitude: 59.70962, longitude: 30.64674, is_on_ground: false, generated_ts: 1522782150}, created_at: ~U[2026-03-26 01:51:48.365000Z], metadata: %{}}]

20:51:48.365 [debug] FlightTracker.App.Projectors.Aircraft confirming receipt of event 184 of events: [%Commanded.EventStore.RecordedEvent{event_id: "659d6122-1aeb-42eb-bb2d-ebc20ac829ee", event_number: 184, stream_id: "aircraft-400159", stream_version: 23, causation_id: "44254b5e-bdee-4ab4-9ccc-7afed4d5473c", correlation_id: "b7f0d29e-4f76-4aae-91ce-6e322edd27e6", event_type: "Elixir.FlightTracker.App.Events.PositionUpdated", data: %FlightTracker.App.Events.PositionUpdated{icao_address: "400159", altitude: 2650, latitude: 59.70962, longitude: 30.64674, is_on_ground: false, generated_ts: 1522782150}, created_at: ~U[2026-03-26 01:51:48.365000Z], metadata: %{}}]

20:51:48.365 [debug] Acknowledging event 184

#
# Run the following command
# 
Mix.Task.rerun("get_aircraft_state", ["400159"])

#
# Something like this will be printed to the console
#
%FlightTracker.App.Projectors.Aircraft{
  icao_address: "400159",
  squawk_code: 1017,
  callsign: "SDM6244",
  flight_id: "1",
  aircraft_id: "1",
  altitude: 2650,
  latitude: 59.70962,
  longitude: 30.64674,
  ground_speed: 202.0,
  track: 314.0,
  vertical_rate: -512,
  is_on_ground: false,
  is_emergency: false,
  updated_ts: 1522782150
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
