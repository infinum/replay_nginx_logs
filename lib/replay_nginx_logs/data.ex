defmodule ReplayNginxLogs.Data do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_args) do
    state = %{
      count: 0,
      started: 0,
      ended: 0,
      success: 0,
      error: 0,
      logs: [],
      statuses: %{},
      lectures: %{},
      current_timestamp: nil
    }

    {:ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:enqueued, line, delay}, state) do
    state = Map.update!(state, :logs, fn logs -> 
      new_logs = [{delay, line} | logs] 
      if Enum.count(new_logs) > 60 do 
        {_, popped} = List.pop_at(new_logs, -1)
        popped
      else 
        new_logs
      end
    end)
    {:noreply, state}
  end

  def handle_cast(:count, state) do
    state = Map.update!(state, :count, fn num -> num + 1 end)
    {:noreply, state}
  end

  def handle_cast(:started, state) do
    state = Map.update!(state, :started, fn num -> num + 1 end)
    {:noreply, state}
  end

  def handle_cast(:ended, state) do
    state = Map.update!(state, :ended, fn num -> num + 1 end)
    {:noreply, state}
  end

  def handle_cast(:success, state) do
    state = Map.update!(state, :success, fn num -> num + 1 end)
    {:noreply, state}
  end

  def handle_cast(:error, state) do
    state = Map.update!(state, :error, fn num -> num + 1 end)
    {:noreply, state}
  end

  def handle_cast({:status, status}, state) do
    statuses = Map.update(state[:statuses], status, 1, fn num -> num + 1 end)
    state = Map.put(state, :statuses, statuses)
    {:noreply, state}
  end

  def handle_cast({:lectures, lecture_path, active_stream}, state) do
    lectures = Map.put(state[:lectures], lecture_path, active_stream)
    state = Map.put(state, :lectures, lectures)
    {:noreply, state}
  end

  def handle_cast({:current_timestamp, timestamp}, state) do
    state = Map.put(state, :current_timestamp, timestamp)
    {:noreply, state}
  end
end
