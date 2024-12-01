defmodule Day01 do
  def find_the_answer_p1() do
    "data/day_01.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game()
  end

  def find_the_answer_p2() do
    nil
  end

  def play_the_game(input) do
    {left_side, right_side} = input

    left_list = Enum.sort(left_side)
    right_list = Enum.sort(right_side)

    {left_list, right_list}

    left_list
    |> Enum.with_index()
    |> Enum.reduce([], fn {left_item, idx}, acc ->
      right_item = Enum.at(right_list, idx)
      distance = abs(left_item - right_item)
      [distance | acc]
    end)
    |> Enum.sum()
  end

  def parse(input) do
    input
    |> Enum.reduce({[], []}, fn input_pair_str, acc ->
      [left_item, right_item] =
        input_pair_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {left_list, right_list} = acc

      {
        [left_item | left_list],
        [right_item | right_list]
      }
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
