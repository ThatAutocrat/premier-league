defmodule FootballTrackerWeb.Router do
  use FootballTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FootballTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", FootballTrackerWeb do
    pipe_through :browser

    live "/", FootballLive, :index
  end
end
