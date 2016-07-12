defmodule WebmonitorAgent.MonitorApi do
  use Maru.Router

  params do
    requires :url, type: String, regexp: ~r/.*/
  end

  alias WebmonitorAgent.Checker
  require Logger
  namespace :monitor do
    get do
      url = params[:url]
      Logger.debug "checking monitor #{url}"
      case Checker.ping(url) do
        {:ok, stats} ->
          Logger.debug("monitor #{url} is up, response time is #{stats.response_time_ms}ms")
          json conn, %{ status: :up, stats: stats }
        {:our_network_is_down, response} ->
          Logger.error("OUR_NETWORK_IS_DOWN #{inspect(response)}")
          json conn, %{status: :unknown, error: inspect(response)}
        {:error, reason} ->
          Logger.debug("monitor #{url} is down")
          json conn, %{status: :down, error: inspect(reason)}
      end
    end
  end

end
