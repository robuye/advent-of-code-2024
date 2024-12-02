defmodule Day02 do
  def find_the_answer_p1() do
    "data/day_02.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_02.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p2()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.map(&check_row/1)
    |> Enum.count(& &1)
  end

  def play_the_game_p2(input) do
    input
    |> Enum.map(fn row ->
      length(row)..0
      |> Enum.reduce_while(nil, fn i, _acc ->
        # Index is out of bounds by 1 therefore delete_at will return complete row
        # on first iteration.
        new_row = List.delete_at(row, i)

        if check_row(new_row) do
          {:halt, true}
        else
          {:cont, false}
        end
      end)
    end)
    |> Enum.count(& &1)
  end

  def check_row(row) do
    row = parse_row(row)
    [_, row_direction] = Enum.at(row, 0)

    row
    |> Enum.all?(fn
      [diff_ok, nil] ->
        diff_ok

      [diff_ok, direction] ->
        diff_ok and direction == row_direction
    end)
  end

  def parse_row(row) do
    row
    |> Enum.chunk_every(2, 1)
    |> Enum.map(fn
      [a, b] ->
        diff_ok = abs(a - b) in 1..3
        direction = if(a > b, do: :desc, else: :asc)

        [diff_ok, direction]

      [_a] ->
        [true, nil]
    end)
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
