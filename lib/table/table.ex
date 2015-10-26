defmodule Pokex.Table do
  alias Pokex.Table.Seat
  alias Pokex.Player
  alias Pokex.Deck
  use GenServer

  defstruct [
    deck: Deck.new,
    seats: [
      "1":   nil,
      "2":   nil,
      "3":   nil,
      "4":   nil,
      "5":   nil,
      "6":   nil,
      "7":   nil,
      "8":   nil,
      "9":   nil,
      "10":  nil
    ],
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
    GenServer.call(pid, {:sit, player})
  end

  def sit(pid, seat, player) do
    GenServer.call(pid, {:sit, seat, player})
  end

  def stand(pid, seat) do
    GenServer.call(pid, {:stand, seat})
  end

  def seats(pid) do
    GenServer.call(pid, :seats)
  end

  def players(pid) do
    GenServer.call(pid, :players)
  end

  ### Server (callbacks)
  def handle_call({:sit, player}, from, state) do
    case Enum.find(state.seats, fn ({_, seat}) -> seat == nil end) do
      {open_position, _} -> handle_call({:sit, open_position, player}, from, state)
      nil                -> {:reply, {:error, "Table full"}, state}
    end
  end

  def handle_call({:sit, position, player}, from, state) when position |> is_integer do
    position =
      position
      |> Integer.to_string
      |> String.to_atom

    handle_call({:sit, position, player}, from, state)
  end

  def handle_call({:sit, position, player}, _, state) when position |> is_atom do
    try do
      {:ok, nil} = Keyword.fetch(state.seats, position)
      false = player |> Player.sitting?

      seat  = player |> Seat.new

      player |> Player.sit(self, seat)

      seats =
        state.seats
        |> Keyword.put(position, seat)
        |> sort_seats

      {:reply, {:ok, seat}, %__MODULE__{state | seats: seats}}
    rescue
      _ -> {:reply, {:error, "Table full or already sitting at a table"}, state}
    end
  end

  def handle_call({:stand, seat}, _, state) do
    {position, _} =
      state.seats
      |> Enum.find(fn ({_, s}) -> s == seat end)

    seats =
      state.seats
      |> Keyword.put(position, nil)
      |> sort_seats

    {:reply, :ok, %__MODULE__{state | seats: seats}}
  end

  def handle_call(:seats, _, state) do
    {:reply, state.seats, state}
  end

  def handle_call(:players, _, state) do
    players =
      state.seats
      |> Enum.filter(fn ({_, seat}) ->
        case seat do
          nil -> false
          _   -> true
        end
      end)
      |> Enum.map(fn ({_, seat}) ->
        Seat.player(seat)
      end)
      {:reply, players, state}
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
