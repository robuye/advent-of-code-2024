defmodule Day13 do
  def find_the_answer_p1() do
    "data/day_13.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(inputs) do
    inputs
    |> Enum.map(fn input ->
      0..100
      |> Enum.reduce([], fn a_presses, acc ->
        0..100
        |> Enum.reduce(acc, fn b_presses, acc ->
          x_distance = input.a.x * a_presses + input.b.x * b_presses
          y_distance = input.a.y * a_presses + input.b.y * b_presses

          new_result = %{
            a_presses: a_presses,
            b_presses: b_presses,
            x_distance: x_distance,
            y_distance: y_distance,
            total_cost: a_presses * 3 + b_presses * 1
          }

          if x_distance == input.prize.x and y_distance == input.prize.y do
            [new_result | acc]
          else
            acc
          end
        end)
      end)
    end)
    |> List.flatten()
    |> Enum.map(& &1.total_cost)
    |> Enum.sum()
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [a_str, b_str, p_str] ->
      [[a_x_str], [a_y_str]] = Regex.scan(~r/\d+/, a_str)
      [[b_x_str], [b_y_str]] = Regex.scan(~r/\d+/, b_str)
      [[p_x_str], [p_y_str]] = Regex.scan(~r/\d+/, p_str)

      %{
        a: %{x: String.to_integer(a_x_str), y: String.to_integer(a_y_str)},
        b: %{x: String.to_integer(b_x_str), y: String.to_integer(b_y_str)},
        prize: %{x: String.to_integer(p_x_str), y: String.to_integer(p_y_str)}
      }
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
