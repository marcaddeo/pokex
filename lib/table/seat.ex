defmodule Pokex.Table.Seat do
  use GenServer
  defstruct player: nil, playing: false, bet: 0, blind: false, button: false

  def new(player) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{player: player})
    pid
  end

  def blind(pid, blind) do
    GenServer.cast(pid, {:blind, blind})
  end

  def blind?(pid) do
    GenServer.call(pid, :blind?)
  end

  def button(pid, button) do
    GenServer.cast(pid, {:button, button})
  end

  def button?(pid) do
    GenServer.call(pid, :button?)
  end

  def bet(pid, amount) do
    GenServer.cast(pid, {:bet, amount})
  end

  def bets(pid) do
    GenServer.call(pid, :bets)
  end

  def player(pid) do
    GenServer.call(pid, :player)
  end

  def playing?(pid) do
    GenServer.call(pid, :playing?)
  end

  def playing(pid, playing) do
    GenServer.cast(pid, {:playing, playing})
  end

  ### Server (callbacks)
  def handle_cast({:blind, blind}, state) do
    {:noreply, %__MODULE__{state | blind: blind}}
  end

  def handle_call(:blind?, _, state) do
    {:reply, state.blind, state}
  end

  def handle_cast({:button, button}, state) do
    {:noreply, %__MODULE__{state | button: button}}
  end

  def handle_call(:button?, _, state) do
    {:reply, state.button, state}
  end

  def handle_cast({:bet, amount}, state) do
    {:noreply, %__MODULE__{state | bet: state.bet + amount}}
  end

  def handle_call(:bets, _, state) do
    {:reply, state.bet, state}
  end

  def handle_call(:player, _, state) do
    {:reply, state.player, state}
  end

  def handle_call(:playing?, _, state) do
    {:reply, state.playing, state}
  end

  def handle_cast({:playing, playing}, state) do
    {:noreply, %__MODULE__{state | playing: playing}}
  end
end
