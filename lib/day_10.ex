defmodule Day10 do
  def find_the_answer_p1() do
    "data/day_10.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_10.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p2()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.filter(fn {_k, v} -> v == 0 end)
    |> Enum.reduce([], fn {{x, y}, _}, acc ->
      state =
        dfs(%{
          board: input,
          trails: [],
          start_at: {x, y}
        })

      [length(Enum.uniq(state.trails)) | acc]
    end)
    |> Enum.sum()
  end

  def play_the_game_p2(input) do
    input
    |> Enum.filter(fn {_k, v} -> v == 0 end)
    |> Enum.reduce([], fn {{x, y}, _}, acc ->
      state =
        dfs(%{
          board: input,
          trails: [],
          start_at: {x, y}
        })

      [length(state.trails) | acc]
    end)
    |> Enum.sum()
  end

  def dfs(state, visited \\ []) do
    current_location_h = state.board[state.start_at]
    {current_x, current_y} = state.start_at
    visited = [{current_x, current_y} | visited]

    state =
      if(current_location_h == 9,
        do: %{state | trails: [{current_x, current_y} | state.trails]},
        else: state
      )

    state.board
    |> Enum.filter(fn
      {{x, _y}, _h} when x > current_x + 1 or x < current_x - 1 -> false
      {{_x, y}, _h} when y > current_y + 1 or y < current_y - 1 -> false
      {{x, y}, __h} when x != current_x and y != current_y -> false
      {{_x, _y}, h} when h != current_location_h + 1 -> false
      _ -> true
    end)
    |> Enum.reject(fn {coordinates, _h} -> Enum.member?(visited, coordinates) end)
    |> Enum.reduce(state, fn {coordinates, _h}, acc ->
      dfs(%{acc | start_at: coordinates}, visited)
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn
        {".", x} -> {{x, y}, -1}
        {chr, x} -> {{x, y}, String.to_integer(chr)}
      end)
    end)
    |> Enum.into(%{})
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
