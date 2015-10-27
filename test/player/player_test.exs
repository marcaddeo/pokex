defmodule Pokex.Player.PlayerTest do
  alias Pokex.Table
  alias Pokex.Player
  use ExUnit.Case

  test "a player can sit down at a table" do
    table = Table.new
    player = Player.new

    :ok = Player.sit(player, table)

    assert table |> player_count == 1
    assert player |> Player.sitting? == true
  end

  test "a player can only sit at one table" do
    table1 = Table.new
    table2 = Table.new
    player = Player.new

    assert table1 |> player_count == 0
    assert table2 |> player_count == 0

    :ok = Player.sit(player, table1)
    {:error, _} = Player.sit(player, table2)

    assert player |> Player.sitting? == true
    assert table1 |> player_count == 1
    assert table2 |> player_count == 0
  end

  test "a player cannot sit at a full table" do
    table = Table.new

    1..10
    |> Enum.each(fn (_) ->
      Player.sit(Player.new, table)
    end)

    assert table |> player_count == 10

    {error, _} = Player.new |> Player.sit(table)

    assert error == :error

    {error, _} = Player.new |> Player.sit(table, 2)

    assert error == :error
  end

  test "a player can stand up from a table" do
    table = Table.new
    player = Player.new

    assert table |> player_count == 0

    :ok = Player.sit(player, table)

    assert table |> player_count == 1

    assert player |> Player.sitting? == true

    :ok = player |> Player.stand

    assert player |> Player.sitting? == false

    assert table |> player_count == 0
  end

  defp player_count(table) do
    table
    |> Table.players
    |> length
  end
end
