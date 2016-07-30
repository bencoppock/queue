defmodule Queue.Provider do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    initial_state =
      for n <- 1..20 do
        "Number #{n}"
      end

    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    {:producer, initial_state}
  end

  def handle_demand(demand, state) do
    {taken, left} = Enum.split(state, demand)
    {:noreply, taken, left}
  end
end
