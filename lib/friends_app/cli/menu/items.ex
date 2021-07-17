defmodule FriendsApp.CLI.Menu.Items do
  alias FriendsApp.CLI.Menu

  def all, do: [
    %Menu{ label: 'Add a friend', id: :create },
    %Menu{ label: 'List all friends', id: :read },
    %Menu{ label: 'Update a friend', id: :update },
    %Menu{ label: 'Delete a friend', id: :delete }
  ]
end
