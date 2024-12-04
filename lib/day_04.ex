defmodule Day04 do
  def find_the_answer_p1() do
    "data/day_04.txt"
    |> read_the_input()
    |> play_the_game_p1()
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
    |> Enum.flat_map(fn {x, y} -> check_coordinates(~w[X M A S], x, y, board) end)
    |> length()
  end

  defp check_coordinates(look_for, from_x, from_y, board) do
    look_for_range = 0..(length(look_for) - 1)

    [
      # right, left, up, down
      Enum.map(look_for_range, &{from_x + &1, from_y}),
      Enum.map(look_for_range, &{from_x - &1, from_y}),
      Enum.map(look_for_range, &{from_x, from_y + &1}),
      Enum.map(look_for_range, &{from_x, from_y - &1}),
      # diagonals: up-right, up-left, down-right, down-left
      Enum.map(look_for_range, &{from_x + &1, from_y + &1}),
      Enum.map(look_for_range, &{from_x - &1, from_y + &1}),
      Enum.map(look_for_range, &{from_x + &1, from_y - &1}),
      Enum.map(look_for_range, &{from_x - &1, from_y - &1})
    ]
    |> Enum.filter(fn coordinates ->
      build_word_from_coordinates(coordinates, board) == look_for
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
