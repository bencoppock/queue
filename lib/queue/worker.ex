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
      %{id: task_id, payload: payload} = task
      {module, function, args} = :erlang.binary_to_term(payload)

      task(module, function, args)
      |> Task.yield(1000)
      |> yield_to_status(task)
      |> update(task_id)
    end

    {:noreply, [], state}
  end

  defp task(module, function, args) do
    Task.Supervisor.async_nolink(Queue.TaskSupervisor, module, function, args)
  end

  defp yield_to_status({:ok, _}, _task) do
    "success"
  end
  defp yield_to_status({:exit, _reason}, _task) do
    "error"
  end
  defp yield_to_status(nil, task) do
    Task.shutdown(task)
    "timeout"
  end

  defp update(status, task_id) do
    Queue.update_status(task_id, status)
  end
end
