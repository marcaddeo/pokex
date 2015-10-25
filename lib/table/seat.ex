defmodule Pokex.Table.Seat do
  use GenServer
  defstruct player: nil, playing: false, bet: 0

  def new(player) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{player: player})
    pid
  end
end
