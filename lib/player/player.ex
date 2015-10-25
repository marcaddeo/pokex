defmodule Pokex.Player do
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
end
