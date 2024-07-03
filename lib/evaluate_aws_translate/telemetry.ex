defmodule EvaluateAwsTranslate.Telemetry do
  @moduledoc false

  @doc """
  Attaches to `[:finch, :recv, :stop]` telemetry events.
  """
  def start_link() do
    :telemetry.attach("finch-recv-stop", [:finch, :recv, :stop], &__MODULE__.handle_event/4, nil)
  end

  @doc """
  Handles telemetry events and aggregates them by host, path, and status.
  """
  def handle_event(_name, measurement, metadata, _config) do
    case metadata.status do
      200 -> IO.puts("#{System.convert_time_unit(measurement[:duration], :native, :millisecond)}ms")
      _ -> :ok
    end
  end
end
