defmodule Pokex.Player do
  alias Pokex.Table.Seat
  alias Pokex.Table
  use GenServer
  defstruct pocket: [], purse: 0, sitting: false, table: nil, seat: nil

  def new do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{})
    pid
  end

  def sit(pid, table, position \\ nil) do
    GenServer.call(pid, {:sit, table, position})
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
  def handle_call({:sit, table, position}, _, state) do
    if not state.sitting do
      case GenServer.call(table, {:sit, self, position}) do
        {:ok, seat} -> {:reply, :ok, %__MODULE__{state | sitting: true, table: table, seat: seat}}
        {:error, message} -> {:reply, {:error, message}, state}
      end
    else
      {:reply, {:error, "Already sitting"}, state}
    end
  end

  def handle_call(:stand, _, state) do
    GenServer.call(state.table, {:stand, state.seat})
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
