defmodule Mix.Tasks.Utils.AddFakeFriends do
  use Mix.Task
  alias FriendsApp.CLI.Friend
  alias NimbleCSV.RFC4180, as: CSVParser

  @shortdoc "Add fake friends on App"
  def run(_) do
    Faker.start()

    create_friends([], 50)
    |> CSVParser.dump_to_iodata()
    |> save_csv_file
  end

  defp create_friends(list, count) when count <= 1 do
    list ++ [randon_list_friend()]
  end

  defp create_friends(list, count) do
    list ++ [randon_list_friend()] ++ create_friends(list, count - 1)
  end

  defp randon_list_friend do
    %Friend{
      name: Faker.Person.PtBr.name(),
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnUs.phone()
    }
    |> Map.from_struct()
    |> Map.values()
  end

  defp save_csv_file(data) do
    Application.fetch_env!(:friends_app, :csv_file_path)
    |> File.write!(data, [:append])
  end
end
