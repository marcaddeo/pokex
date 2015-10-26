defmodule Pokex.Player do
  alias Pokex.Table.Seat
  alias Pokex.Table
  use GenServer
  defstruct pocket: [], purse: 0, sitting: false, table: nil, seat: nil

  def new do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{})
    pid
  end

  def sit(pid, table, seat) do
    GenServer.cast(pid, {:sit, table, seat})
  end

  def stand(pid) do
    GenServer.call(pid, :stand)
  end

  def sitting?(pid) do
    GenServer.call(pid, :sitting?)
  end

  def bet(pid, amount) do
    GenServer.cast({:bet, amount})
  end

  ### Server (callbacks)
  def handle_cast({:sit, table, seat}, state) do
    {:noreply, %__MODULE__{state | sitting: true, table: table, seat: seat}}
  end

  def handle_call(:stand, _, state) do
    :ok = Table.stand(state.table, state.seat)
    {:reply, :ok, %__MODULE__{state | sitting: false, table: nil, seat: nil}}
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
