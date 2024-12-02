defmodule Day02 do
  def find_the_answer_p1() do
    "data/day_02.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.map(fn row ->
      row
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        diff = abs(a - b)

        diff_ok = diff > 0 and diff < 4

        direction = if(a > b, do: :desc, else: :asc)

        [diff_ok, direction]
      end)
    end)
    |> Enum.map(fn row ->
      [_, row_direction] = Enum.at(row, 0)

      row
      |> Enum.all?(fn [diff_ok, direction] ->
        diff_ok and direction == row_direction
      end)
    end)
    |> Enum.count(& &1)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
