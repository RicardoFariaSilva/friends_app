defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias FriendsApp.CLI.Menu
  alias FriendsApp.CLI.Friend
  alias NimbleCSV.RFC4180, as: CSVParser

  def perform(chosen_menu_item) do
    case chosen_menu_item do
      %Menu{ id: :create, label: _ } -> create()
      %Menu{ id: :read, label: _ } -> read()
      %Menu{ id: :update, label: _ } -> update()
      %Menu{ id: :delete, label: _ } -> delete()
    end
    FriendsApp.CLI.Menu.Choice.start()
  end

  defp create do
    collect_data()
    |> transform_on_wrapped_list()
    |> prepare_list_to_save_csv()
    |> save_csv_file([:append])
  end

  defp transform_on_wrapped_list(struct) do
    struct
    |> Map.from_struct()
    |> Map.values
    |> wrap_in_list()
  end

  def prepare_list_to_save_csv(list) do
    list
    |> CSVParser.dump_to_iodata()
  end

  defp collect_data do
    Shell.cmd("clear")
    Shell.info("Digit friend data...")

    %Friend{
      name: prompt_message("Digit name: "),
      email: prompt_message("Digit email: "),
      phone: prompt_message("Digit phone: ")
    }
  end

  defp prompt_message(message) do
    Shell.prompt(message)
    |> String.trim()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp save_csv_file(data, mode \\ []) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!(data, mode)
  end

  defp read() do
    get_struct_list_from_csv()
    |> show_friends
  end

  defp get_struct_list_from_csv() do
    read_csv_file()
    |> parse_csv_file_to_list
    |> csv_list_to_friend_struct_list
  end

  defp read_csv_file() do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.read!()
  end

  defp parse_csv_file_to_list(csv_file) do
    csv_file
    |> CSVParser.parse_string(skip_headers: true)
  end

  defp csv_list_to_friend_struct_list(list) do
    list
    |> Enum.map( fn [email, name, phone] ->
      %Friend{name: name, email: email, phone: phone}
    end)
  end

  defp show_friends(friends_list) do
    friends_list
    |> Scribe.console(data: [{"Name", :name}, {"Email", :email}, {"Phone", :phone}])
  end

  defp delete() do
    Shell.cmd("clear")

    prompt_message("Digit email to be deleted: ")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_delete()
    |> delete_and_save()
  end

  defp search_friend_by_email(email) do
    get_struct_list_from_csv()
    |> Enum.find(:not_found, fn list -> list.email == email end )
  end

  def check_friend_found(friend) do
    case friend do
      :not_found ->
        Shell.cmd("clear")
        Shell.error("Friend not found... ")
        Shell.prompt("Press ENTER to continue")
        FriendsApp.CLI.Menu.Choice.start()

      _ -> friend
    end
  end

  def confirm_delete(friend) do
    Shell.cmd("clear")
    Shell.info("Friend found...")

    show_friend(friend)

    case Shell.yes?("Do you really wanna delete this friend?") do
      true -> friend
      false -> :error
    end
  end

  def show_friend(friend) do
    friend
    |> Scribe.print(data: [{"Name", :name}, {"Email", :email}, {"Phone", :phone}])
  end

  defp delete_and_save(friend) do
    case friend do
      :error ->
        Shell.info("Ok, friend will NOT be deleted...")
        Shell.prompt("Press ENTER to continue")

      _ ->
        get_struct_list_from_csv()
        |> delete_friend_from_struct_list(friend)
        |> friend_list_to_csv()
        |> prepare_list_to_save_csv()
        |> save_csv_file()

        Shell.info("Friend successfully deleted!")
        Shell.prompt("Press ENTER to continue")
    end
  end

  defp delete_friend_from_struct_list(list, friend) do
    list
    |> Enum.reject(fn elem -> elem.email == friend.email end)
  end

  defp friend_list_to_csv(list) do
    list
    |> Enum.map( fn item ->
      [item.email, item.name, item.phone]
    end)
  end

  defp update do
    Shell.cmd("clear")

    prompt_message("Digit friend email to update:")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_update()
    |> do_update()
  end

  defp confirm_update(friend) do
    Shell.cmd("clear")
    Shell.info("Found...")

    show_friend(friend)

    case Shell.yes?("Do you really wanna update this friend?") do
      true -> friend
      false -> :error
    end
  end

  defp do_update(friend) do
    Shell.cmd("clear")

    updated_friend = collect_data()

    get_struct_list_from_csv()
    |> delete_friend_from_struct_list(friend)
    |> friend_list_to_csv
    |> prepare_list_to_save_csv
    |> save_csv_file()

    updated_friend
    |> transform_on_wrapped_list()
    |> prepare_list_to_save_csv()
    |> save_csv_file([:append])

    Shell.info("Friend updated successfully!")
    Shell.prompt("Press ENTER to continue")
  end
end
