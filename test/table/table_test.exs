defmodule Pokex.TableTest do
  alias Pokex.Table
  alias Pokex.Player
  use ExUnit.Case

  test "a table can list its players" do
    table = Table.new
    players = [Player.new, Player.new, Player.new]

    for player <- players, do: player |> Player.sit(table)

    assert table |> Table.players == players
  end

  test "a table can list its seats" do
    table = Table.new
    player1 = Player.new
    player2 = Player.new
    player3 = Player.new

    player1 |> Player.sit(table)
    player2 |> Player.sit(table)
    player3 |> Player.sit(table, 9)

    seats = [
      "1": player1 |> Player.seat,
      "2": player2 |> Player.seat,
      "3": nil,
      "4": nil,
      "5": nil,
      "6": nil,
      "7": nil,
      "8": nil,
      "9": player3 |> Player.seat,
      "10": nil,
    ]

    assert table |> Table.seats == seats
  end
end
