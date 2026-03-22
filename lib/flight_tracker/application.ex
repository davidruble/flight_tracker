defmodule FlightTracker.Application do
  use Application

  require OptionParser

  alias FlightTracker.App

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: FlightTracker.Worker.start_link(arg)
      {App.Supervisor, parse_cmd_args()}
    ]

    opts = [strategy: :one_for_one, name: FlightTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Parses the command line arguments.
  #
  # Supports the following arguments:
  #  - `--filename` or `-f` followed by the name of a file that resides in `priv/data`
  defp parse_cmd_args() do
    {options, _remaining_args, _invalid_options} =
      OptionParser.parse(
        System.argv(),
        switches: [
          filename: :string
        ],
        aliases: [
          f: :filename
        ]
      )

    options
  end
end
