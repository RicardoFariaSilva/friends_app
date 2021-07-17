defmodule Mix.Tasks.Start do
  use Mix.Task

  @shortdoc "Start app"
  def run(_) do
    FriendsApp.init()
  end
end
