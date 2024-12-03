defmodule Day03 do
  def find_the_answer_p1() do
    "data/day_03.txt"
    |> read_the_input()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_03.txt"
    |> read_the_input()
    |> play_the_game_p2()
  end

  def play_the_game_p1(input) do
    ~r/mul\(\d{1,3},\d{1,3}\)/
    |> Regex.scan(input)
    |> List.flatten()
    |> Enum.map(&parse/1)
    |> Enum.sum()
  end

  def play_the_game_p2(input) do
    ~r/(mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\))/
    |> Regex.scan(input, capture: :all_but_first)
    |> List.flatten()
    |> Enum.map(&parse/1)
    |> Enum.reduce(%{state: :accept, items: []}, fn
      n, acc when is_number(n) ->
        if acc.state == :accept do
          Map.put(acc, :items, [n | acc.items])
        else
          acc
        end

      action, acc ->
        %{acc | state: action}
    end)
    |> then(&Enum.sum(&1.items))
  end

  def parse("mul" <> _ = val) do
    [a, b] =
      Regex.run(~r/(\d+),(\d+)/, val, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    a * b
  end

  def parse("do()"), do: :accept
  def parse("don't()"), do: :reject

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
