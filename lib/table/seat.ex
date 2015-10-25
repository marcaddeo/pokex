defmodule Pokex.Table.Seat do
  defstruct player: nil, playing: false

  def new(player) do
    %__MODULE__{player: player}
  end
end
