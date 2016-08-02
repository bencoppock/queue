defmodule Queue.Worker do
  alias Experimental.GenStage
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :whatever)
  end

  def init(initial_state) do
    {:consumer, initial_state, subscribe_to: [Queue.Provider]}
  end

  def handle_events(events, _from, state) do
    Enum.each(events, fn event ->
      %{id: task_id, payload: payload} = event
      {module, function, args} = :erlang.binary_to_term(payload)

      task = task(module, function, args)

      Task.yield(task, 1000)
      |> yield_to_status(task)
      |> update(task_id)
    end)

    {:noreply, [], state}
  end

  defp task(module, function, args) do
    Task.Supervisor.async_nolink(Queue.TaskSupervisor, module, function, args)
  end

  defp yield_to_status({:ok, _}, _async_task) do
    "success"
  end
  defp yield_to_status({:exit, _reason}, _async_task) do
    "error"
  end
  defp yield_to_status(nil, async_task) do
    # This is not atomic; if the task completes between calling this method
    # and killing the task, do we mark down "timeout" for a successful task?
    # What happens if we try to kill a task that is already terminated?
    Task.shutdown(async_task, :brutal_kill)
    "timeout"
  end

  defp update(status, task_id) do
    Queue.update_status(task_id, status)
  end
end
