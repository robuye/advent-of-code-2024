defmodule Day03 do
  def find_the_answer_p1() do
    "data/day_03.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
  end

  def parse(input) do
    Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, input)
    |> List.flatten()
    |> Enum.map(&Regex.scan(~r/(\d+),(\d+)/, &1, capture: :all_but_first))
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
