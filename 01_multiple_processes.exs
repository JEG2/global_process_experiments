defmodule AGlobalProcess do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: {:global, __MODULE__})
  end

  def init(_args) do
    IO.puts "Starting #{inspect self()}…"
    {:ok, %{ }}
  end
end

AGlobalProcess.start_link([])
|> IO.inspect()

AGlobalProcess.start_link([])
|> IO.inspect()
