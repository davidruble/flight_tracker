defmodule FlightTracker.App.Gateways.FileInjector do
  @moduledoc """
  Injects data from a file into the application in a stream similar to a real ADS-B receiver.
  """
  use GenStage, restart: :transient
  require Logger

  alias FlightTracker.App.Services.{
    AppService,
    DataMapper
  }

  alias NimbleCSV.RFC4180, as: CSV

  @doc "Triggers the process of loading the file and sending data into the domain"
  def start_link(filename) do
    Logger.info("Initializing file injector")
    stream = build_stream(filename)
    {:ok, line_producer} = GenStage.from_enumerable(stream)
    GenStage.start_link(__MODULE__, line_producer, name: __MODULE__)
  end

  @impl true
  def init(line_producer) do
    {:consumer, :no_state, subscribe_to: [{line_producer, max_demand: 5}]}
  end

  @impl true
  def handle_events(lines, _from, state) do
    lines
    |> Enum.map(&DataMapper.basestation_sbs_to_map/1)
    |> Enum.each(fn
      {:ok, data} -> AppService.update_aircraft(data, blocking: true)
      {:error, :malformed_data} -> :ok
    end)

    {:noreply, [], state}
  end

  @spec build_stream(String.t()) :: Enumerable.t(list(String.t()))
  defp build_stream(filename) do
    Application.app_dir(:flight_tracker, "priv/data/#{filename}")
    |> File.stream!()
    |> CSV.parse_stream(skip_headers: false)
    |> Stream.map(fn line ->
      # Simulate a delay between elements
      Process.sleep(500)

      # See https://hexdocs.pm/nimble_csv/NimbleCSV.html#module-binary-references
      Enum.map(line, &:binary.copy/1)
    end)
  end
end
