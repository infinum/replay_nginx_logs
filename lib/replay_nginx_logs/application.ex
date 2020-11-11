defmodule ReplayNginxLogs.Application do
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Subscription

  import Ratatouille.View

  def init(_context),
    do: %{
      count: 0,
      started: 0,
      ended: 0,
      success: 0,
      error: 0,
      logs: [],
      statuses: %{},
      current_timestamp: nil
    }

  def update(model, msg) do
    case msg do
      :tick ->
        GenServer.call(ReplayNginxLogs.Data, :state)

      _ ->
        model
    end
  end

  def subscribe(_model) do
    Subscription.batch([
      Subscription.interval(100, :tick)
    ])
  end

  def render(model) do
    view do
      row do
        column size: 12 do
          panel title: "Info" do
            label(content: "Current timestamp: #{model[:current_timestamp]}")
            label(content: "Counter: #{model[:count]}")
            label(content: "Current: #{model[:started] - model[:ended]}")
            label(content: "Started: #{model[:started]}")
            label(content: "Ended: #{model[:ended]}")
            label(content: "Success: #{model[:success]}")
            label(content: "Errors: #{model[:error]}")
            label(content: "Statuses: #{inspect(model[:statuses])}")
          end
        end
      end

      row do
        column size: 12 do
          panel title: "Logs" do
            Enum.map(
              Enum.slice(model[:logs], 0..60),
              fn l -> label(content: inspect(l)) end
            )
          end
        end
      end
    end
  end
end
