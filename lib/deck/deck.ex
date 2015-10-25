defmodule Pokex.Deck do
  defstruct cards: nil
  alias Pokex.Deck.Card

  @suits [:clubs, :diamonds, :hearts, :spades]
  @values [:a, :"2", :"3", :"4", :"5", :"6", :"7", :"8", "9", :"10", :j, :q, :k]

  def new do
    cards = (for value <- @values, suit <- @suits, do: %Card{value: value, suit: suit})
    |> Enum.shuffle

    %__MODULE__{cards: cards}
  end
end
