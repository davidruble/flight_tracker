# FlightTracker

`flight_tracker` is an event-sourced [ADS-B](https://www.faa.gov/about/office_org/headquarters_offices/avs/offices/afx/afs/afs400/afs410/ads-b) flight tracking system written in Elixir. It was made just for fun because 1. I like aviation, 2. I like Elixir, and 3. I like event sourcing. It's probably overkill for its purpose but who cares!

The data is ingested in [BaseStation SBS format](http://woodair.net/sbs/article/barebones42_socket_data.htm) from either a csv file or [dump1090](https://github.com/antirez/dump1090) hooked up to an ADS-B receiver like an [RTL-SDR](https://www.rtl-sdr.com/about-rtl-sdr/).

Inspired by an exercise in the book _Real-World Event Sourcing_ published by The Pragmatic Programmers.

## Development

- Intall Elixir >= 1.19
- After cloning run `git config --local core.hooksPath .githooks/` to setup git hooks
- I recommend installing VS Code with the following plugins and enable Format on Save:
  - pantajoe.vscode-elixir-credo
  - jakebecker.elixir-ls

## Running The Application

To run locally, use `mix app.start`.

To run in an interactive console, use `iex -S mix`.

TODO: Describe how to run from a file.

TODO: Describe how to run dump1090 alongside the application.

## Flight Plan

- [ ] Read static data from a csv file
- [ ] Read real data from dump1090
- [ ] Create a scheduled task that cleans out old data so it doesn't blow up in size
- [ ] Display flight data in a UI leveraging Phoenix LiveView

## If We Have Enough Fuel

- [ ] Get a wider range of data from an ADS-B data exchange like [ADSBHub](https://www.adsbhub.org/)
- [ ] Leverage a more robust datastore than just `:ets`, probably something like postgres
- [ ] Host the project publicly, possibly with something like [fly.io](https://fly.io/docs/elixir/getting-started/existing/)

## Legal-ish Note

This project was made just for fun with publicly available data and should not be used for commercial purposes or by stalkers.
