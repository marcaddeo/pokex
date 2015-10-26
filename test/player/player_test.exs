defmodule Pokex.Player.PlayerTest do
  alias Pokex.Table
  alias Pokex.Player
  use ExUnit.Case

  test "a player can sit down at a table" do
    table = Table.new
    player = Player.new

    Table.sit(table, player)

    players = table |> player_count

    assert players == 1
    assert player |> Player.sitting? == true
  end

  test "a player can only sit at one table" do
    table1 = Table.new
    table2 = Table.new
    player = Player.new

    assert table1 |> player_count == 0
    assert table2 |> player_count == 0

    Table.sit(table1, player)
    Table.sit(table2, player)

    assert table1 |> player_count == 1
    assert table2 |> player_count == 0
  end

  test "a player cannot sit at a full table" do
    table = Table.new

    1..10
    |> Enum.each(fn (_) ->
      Table.sit(table, Player.new)
    end)

    assert table |> player_count == 10

    {code, _} =
      table
      |> Table.sit(Player.new)

    assert code == :error

    {code, _} =
      table
      |> Table.sit(2, Player.new)

    assert code == :error
  end

  test "a player can stand up from a table" do
    table = Table.new
    player = Player.new

    assert table |> player_count == 0

    {:ok, _} = Table.sit(table, player)

    assert table |> player_count == 1

    assert player |> Player.sitting? == true

    player |> Player.stand

    assert player |> Player.sitting? == false

    assert table |> player_count == 0
  end

  defp player_count(table) do
    table
    |> Table.players
    |> length
  end
end
