defmodule Pokex.Player do
  use GenServer
  defstruct pocket: [], purse: 0

  def new do
    %__MODULE__{}
  end
end
