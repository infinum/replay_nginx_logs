defmodule ReplayNginxLogs.Main do
  use GenServer

  @delay 1000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args) do
    file_path = System.fetch_env!("file")

    GenServer.cast(self(), :start)
    state = %{file_path: file_path, start_timestamp: nil, server_start_timestamp: nil}

    {:ok, state}
  end

  def handle_cast(:start, state) do
    state[:file_path]
    |> File.stream!()
    |> Enum.reduce(state, fn l, acc -> acc = handle_line(l, acc) end)

    {:noreply, state}
  end

  def handle_line(line, state) do
    line_hash =
      line
      |> ReplayNginxLogs.Parser.parse_line()
      |> ReplayNginxLogs.Parser.parse_timestamp()

    GenServer.cast(ReplayNginxLogs.Data, {:current_timestamp, line_hash["timestamp"]})
    enqueue_line(line_hash, state)
  end

  def enqueue_line(line, state) do
    state =
      if state[:start_timestamp] == nil do
        GenServer.cast(
          ReplayNginxLogs.Data,
          {:enqueued, "Start timestamp: #{line["timestamp"]}", 0}
        )

        state
        |> Map.put(:start_timestamp, line["timestamp"])
        |> Map.put(:server_start_timestamp, DateTime.now!("Etc/UTC"))
      else
        state
      end

    data = GenServer.call(ReplayNginxLogs.Data, :state)
    if data[:count] - data[:ended] > 1000, do: Process.sleep(1000)

    line_delay = DateTime.diff(line["timestamp"], state[:start_timestamp], :millisecond)

    server_delay =
      DateTime.diff(DateTime.now!("Etc/UTC"), state[:server_start_timestamp], :millisecond)

    GenServer.start_link(ReplayNginxLogs.RequestTask, {line_delay - server_delay + @delay, line})
    GenServer.cast(ReplayNginxLogs.Data, :count)

    case System.fetch_env("GUI") do
      {:ok, _} ->
        nil

      :error ->
        if rem(data[:count], 1000) == 0, do: IO.inspect({line["timestamp"], data[:count]})
    end

    state
  end
end
