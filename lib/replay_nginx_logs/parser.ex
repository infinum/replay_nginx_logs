defmodule ReplayNginxLogs.Parser do
  use Timex

  def parse_line(line) do
    Regex.named_captures(~r/[\d.]+ - - \[(?<timestamp>.+?)\] "(?<method>\w+) (?<path>\S+) HTTP\/1\.1"/, line)
  end

  def parse_timestamp(line_hash) do
    # 05/Nov/2020:06:25:23 +0000
    {:ok, datetime} = Timex.parse(line_hash["timestamp"], "%d/%b/%Y:%H:%M:%S %z", :strftime)
    Map.put(line_hash, "timestamp", datetime)
  end
end
