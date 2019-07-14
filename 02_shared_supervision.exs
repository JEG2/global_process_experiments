defmodule AGlobalProcess do
  use GenServer

  def start_link(args) do
    case GenServer.start_link(__MODULE__, args, name: {:global, __MODULE__}) do
      {:error, {:already_started, pid}} ->
        {:ok, pid}

      result ->
        result
    end
  end

  def init(_args) do
    IO.puts "Starting #{inspect self()}…"
    {:ok, %{ }}
  end
end

{:ok, first} = Supervisor.start_link([AGlobalProcess], strategy: :one_for_one)
Supervisor.which_children(first)
|> IO.inspect()

{:ok, second} = Supervisor.start_link([AGlobalProcess], strategy: :one_for_one)
Supervisor.which_children(second)
|> IO.inspect()

pid = :global.whereis_name(AGlobalProcess)
ref = Process.monitor(pid)
:ok = Supervisor.stop(first)
receive do
  {:DOWN, ^ref, :process, ^pid, reason} ->
    IO.puts "#{inspect pid} exited for reason #{inspect reason}."
end

:global.whereis_name(AGlobalProcess)
|> IO.inspect()
Supervisor.which_children(second)
|> IO.inspect()
