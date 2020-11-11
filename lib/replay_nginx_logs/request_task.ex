defmodule ReplayNginxLogs.RequestTask do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init({delay, line}) do
    state = %{delay: delay, line: line}
    schedule_work(delay)
    {:ok, state}
  end

  def schedule_work(delay) do
    Process.send_after(self(), :work, delay)
  end

  def handle_info(:work, state) do
    GenServer.cast(ReplayNginxLogs.Data, :started)
    GenServer.cast(ReplayNginxLogs.Data, {:enqueued, state[:line], state[:delay]})

    case ReplayNginxLogs.Request.match(state[:line]) do
      {:ok, response} ->
        GenServer.cast(ReplayNginxLogs.Data, :success)
        GenServer.cast(ReplayNginxLogs.Data, {:status, response.status})

      {:error, :timeout} ->
        GenServer.cast(ReplayNginxLogs.Data, :error)
      {:error, :checkout_timeout} ->
        GenServer.cast(ReplayNginxLogs.Data, :error)
      {:error, :queue_timeout} ->
        GenServer.cast(ReplayNginxLogs.Data, :error)

      {:error, response} ->
        GenServer.cast(ReplayNginxLogs.Data, :error)
        GenServer.cast(ReplayNginxLogs.Data, {:status, response.status})

      {:skip} ->
        nil
    end

    GenServer.cast(ReplayNginxLogs.Data, :ended)
    {:stop, :normal, state}
  end
end
