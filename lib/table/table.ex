defmodule Pokex.Table do
  alias Pokex.Player
  alias Pokex.Seat
  alias Pokex.Deck
  use GenServer

  defstruct [
    deck: Deck.new,
    seats: ["1": nil, "2": nil, "3": nil, "4": nil, "5": nil, "6": nil, "7": nil, "8": nil, "9": nil, "10": nil],
    hand: nil,
    pot: 0,
  ]
  """
  A Table has:
    * One deck
      * A deck has 52 cards, four of each suit
    * One pot
    * 10 seats
      * One player can sit at a seat
    * Many hands, but only one at a time
      * A hand may begin if there are at least two players sitting at the table
      * A hand has many stages
        * Dealing stage
          * The button is passed to the player in the seat to the left
          * Cards are dealt, two to each player and only that player knows the value of their cards
            * The first card is dealt to the player in the small blind seat
          * Compulsary bets are collected
            * Small blind = the player in the seat to the left of the button
              * Small blind is equal to half the minimum bet
            * Big bling = the player in the seat to the left of the small blind
              * Big blind is equal to the minimum bet
        * Preflop betting stage
          * The player in the seat to the left of the big blind begins the bet
            * They must call the big blind in order to stay in, they can also raise or fold
          * Each player after the first can call, raise, or fold
          * Once all players have placed their bet, the preflog stage is completed
        * Flop stage
          * This stage only happens if there are still two remaining players on the hand
          * A single card is burned
          * Three cards are dealt and announced to all players on the table
        * Postflop betting stage
          * This stage, and all further betting stages, are the same as the preflop betting stage but begin with the player to the left of the dealer
        * Turn stage
          * This stage only happens if there are still two remaining players on the hand
          * A single card is burned
          * A single card is dealt and announced to all players on the table
        * Postturn betting stage
        * River stage
          * This stage only happens if there are still two remaining players on the hand
          * A single card is burned
          * A single card is dealt and announced to all players on the table
        * Postriver betting stage
        * Showdown stage
          * If a player is the only player left after the postriver betting stage, he is awarded the bot
            * He also has the choice to show all the other players his cards
            * The hand ends, and a new one begins
          * If two or more players remain, all of their cards are revealed
          * The best hands are then calculated
          * If only one person has the best hand, he is awarded the pot
          * If multiple people have the same best hand, the pot is split between them
            * Need to figure out how to properly split a pot based on peoples bets
              * Side pots, etc
          * The hand ends, and a new one begins
    * Many players
      * A player has a pocket
      * A player has a purse
        * A purse has funds
  """

  def new do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{})
    pid
  end

  def sit(pid, player) do
    GenServer.cast(pid, {:sit, player})
  end

  def sit(pid, seat, player) do
    GenServer.cast(pid, {:sit, seat, player})
  end

  def seats(pid) do
    GenServer.call(pid, :seats)
  end

  ### Server (callbacks)
  def handle_cast({:sit, player}, state) do
    {open_seat, _} = Enum.find(state.seats, fn ({_, player}) -> player == nil end)
    handle_cast({:sit, open_seat, player}, state)
  end

  def handle_cast({:sit, seat, player}, state) when seat |> is_integer do
    seat =
      seat
      |> Integer.to_string
      |> String.to_atom

    handle_cast({:sit, seat, player}, state)
  end

  def handle_cast({:sit, seat, player}, state) when seat |> is_atom do
    try do
      {:ok, nil} = Keyword.fetch(state.seats, seat)
      false = player |> Player.sitting?

      player |> Player.sit(self)

      seats =
        state.seats
        |> Keyword.put(seat, player)
        |> sort_seats

      {:noreply, %__MODULE__{state | seats: seats}}
    rescue
      _ -> {:noreply, state}
    end
  end

  def handle_call(:seats, _, state) do
    {:reply, state.seats, state}
  end

  defp sort_seats(seats) do
    seats
    |> Enum.sort(fn ({a, _}, {b, _}) ->
      a =
        a
        |> Atom.to_string
        |> String.to_integer

      b =
        b
        |> Atom.to_string
        |> String.to_integer

      a < b
    end)
  end
end
