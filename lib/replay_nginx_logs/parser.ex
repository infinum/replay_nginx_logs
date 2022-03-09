defmodule ReplayNginxLogs.Parser do
  use Timex

  def parse_line(line) do
    Regex.named_captures(~r/[\d.]+ - - \[(?<timestamp>.+?)\] "(?<method>\w+) (?<path>\S+) HTTP\/.\.."/, line)
  end

  def parse_timestamp(line_hash) do
    # 05/Nov/2020:06:25:23 +0000
    datetime =
      case Timex.parse(line_hash["timestamp"], "%d/%b/%Y:%H:%M:%S %z", :strftime) do
        {:ok, datetime} -> datetime
        {:error, _} -> IO.inspect line_hash, label: "BAD DATETIME"
      end
    Map.put(line_hash, "timestamp", datetime)
  end
end
