defmodule Day04 do
  def find_the_answer_p1() do
    "data/day_04.txt"
    |> read_the_input()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_04.txt"
    |> read_the_input()
    |> play_the_game_p2()
  end

  def play_the_game_p1(input) do
    board =
      input
      |> String.split("\n", trim: true)

    board
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      0..(String.length(row) - 1)
      |> Enum.map(fn x -> {x, y} end)
    end)
    |> Enum.flat_map(fn {x, y} -> check_xmas(x, y, board) end)
    |> length()
  end

  def play_the_game_p2(input) do
    board =
      input
      |> String.split("\n", trim: true)

    board
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      0..(String.length(row) - 1)
      |> Enum.map(fn x -> {x, y} end)
    end)
    |> Enum.filter(fn {x, y} -> check_mas(x, y, board) end)
    |> length()
  end

  defp check_mas(from_x, from_y, board) do
    valid_mathes = [~w[M A S], ~w[S A M]]

    # going up-right or back, coordinate points A in the middle
    # d1:          d2:
    # [ ][ ][S]    [M][ ][ ]
    # [ ][A][ ]    [ ][A][ ]
    # [M][ ][ ]    [ ][ ][S]
    d1 =
      build_word_from_coordinates(
        [
          {from_x - 1, from_y - 1},
          {from_x, from_y},
          {from_x + 1, from_y + 1}
        ],
        board
      )

    d2 =
      build_word_from_coordinates(
        [
          {from_x - 1, from_y + 1},
          {from_x, from_y},
          {from_x + 1, from_y - 1}
        ],
        board
      )

    d1 in valid_mathes and d2 in valid_mathes
  end

  defp check_xmas(from_x, from_y, board) do
    [
      # right, left, up, down
      Enum.map(0..3, &{from_x + &1, from_y}),
      Enum.map(0..3, &{from_x - &1, from_y}),
      Enum.map(0..3, &{from_x, from_y + &1}),
      Enum.map(0..3, &{from_x, from_y - &1}),
      # diagonals: up-right, up-left, down-right, down-left
      Enum.map(0..3, &{from_x + &1, from_y + &1}),
      Enum.map(0..3, &{from_x - &1, from_y + &1}),
      Enum.map(0..3, &{from_x + &1, from_y - &1}),
      Enum.map(0..3, &{from_x - &1, from_y - &1})
    ]
    |> Enum.filter(fn coordinates ->
      build_word_from_coordinates(coordinates, board) == ~w[X M A S]
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end

  defp build_word_from_coordinates(list_of_coordinates, board) do
    list_of_coordinates
    |> Enum.map(fn
      {x, y} when y >= 0 and x >= 0 ->
        board
        |> Enum.at(y)
        |> case do
          nil -> nil
          str -> String.at(str, x)
        end

      _ ->
        nil
    end)
  end
end
