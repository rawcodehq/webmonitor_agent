defmodule WebmonitorAgent.Router do
  use Maru.Router
  require Logger

  before do
    plug Plug.Logger
    plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json]
  end

  mount WebmonitorAgent.MonitorApi

  get do
    conn
    |> html("<!doctype html>Move along")
  end

  # rescues
  rescue_from Unauthorized do
    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

  rescue_from Maru.Exceptions.NotFound, as: e do
    Logger.error "404: URL Not Found at path /#{e.path_info}"
    conn
    |> put_status(404)
    |> text("Invalid URL")
  end

  rescue_from Maru.Exceptions.MethodNotAllow do
    Logger.error "405: Method Not allowed"
    conn
    |> put_status(405)
    |> text("Method Not Allowed")
  end

  rescue_from [MatchError, UndefinedFunctionError], as: e do
    Logger.error(inspect(e))
    conn
    |> put_status(500)
    |> text("Server error")
  end

  rescue_from :all do
    conn
    |> put_status(500)
    |> text("Server error")
  end

end
