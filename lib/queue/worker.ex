defmodule Queue.Worker do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :whatever)
  end

  def init(initial_state) do
    {:consumer, initial_state, subscribe_to: [{Queue.Provider, max_demand: 1}]}
  end

  def handle_events(work_items, _from, state) do
    for work_item <- work_items do
      IO.inspect {self, work_item}
    end

    {:noreply, [], state}
  end
end
