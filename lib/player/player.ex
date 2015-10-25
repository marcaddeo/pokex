defmodule Pokex.Player do
  alias Pokex.Table.Seat
  use GenServer
  defstruct pocket: [], purse: 0, sitting: false, table: nil, seat: nil

  def new do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{})
    pid
  end

  def sit(pid, table) do
    GenServer.cast(pid, {:sit, table})
  end

  def stand(pid) do
    GenServer.cast(pid, :stand)
  end

  def sitting?(pid) do
    GenServer.call(pid, :sitting?)
  end

  def bet(pid, amount) do
    GenServer.cast({:bet, amount})
  end

  ### Server (callbacks)
  def handle_cast({:sit, table}, state) do
    {:noreply, %__MODULE__{state | sitting: true, table: table}}
  end

  def handle_cast(:stand, state) do
    {:noreply, %__MODULE__{state | sitting: false, table: nil}}
  end

  def handle_call(:sitting?, _, state) do
    {:reply, state.sitting, state}
  end

  def handle_cast({:bet, amount}, state) do
    if amount <= state.purse do
      Seat.bet(state.seat, amount)
      {:noreply, %__MODULE__{state | purse: state.purse - amount}}
    else
      {:noreply, state}
    end
  end
end
