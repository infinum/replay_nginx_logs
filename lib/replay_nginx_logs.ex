defmodule ReplayNginxLogs do
  use Application

  def start(_type, _args) do
    runtime_opts = [
      app: ReplayNginxLogs.Application,
      shutdown: {:application, :replay_nginx_logs},
      name: Ratatouille.Runtime
    ]

    children = [
      {Ratatouille.Runtime.Supervisor, runtime: runtime_opts},
      {ReplayNginxLogs.Main, name: ReplayNginxLogs.Main},
      {ReplayNginxLogs.Data, name: ReplayNginxLogs.Data},
    ]

    # :observer.start()
    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: ReplayNginxLogs.Supervisor
    )
  end

  def stop(_state) do
    # Do a hard shutdown after the application has been stopped.
    #
    # Another, perhaps better, option is `System.stop/0`, but this results in a
    # rather annoying lag when quitting the terminal application.
    System.halt()
  end
end
