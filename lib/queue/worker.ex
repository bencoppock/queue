defmodule Queue.Worker do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :whatever)
  end

  def init(initial_state) do
    {:consumer, initial_state, subscribe_to: [{Queue.Provider, max_demand: 1}]}
  end

  def handle_events(tasks, _from, state) do
    for task <- tasks do
      %{id: id, payload: payload} = task
      {module, function, args} = :erlang.binary_to_term(payload)
      apply(module, function, args)
      id
    end

    {:noreply, [], state}
  end
end
