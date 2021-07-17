defmodule FriendsApp.CLI.Main do
  alias Mix.Shell.IO, as: Shell

  def start_app do
    Shell.cmd("clear")
    welcome_message()
    Shell.prompt("Press ENTER to continue...")
    starts_menu_choice()
  end

  defp welcome_message do
    Shell.info("========== FriendsApp ==============")
    Shell.info("  Welcome to your personal notepad  ")
    Shell.info("====================================")
  end

  defp starts_menu_choice() do
    FriendsApp.CLI.Menu.Choice.start()
  end
end
