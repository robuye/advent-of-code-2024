defmodule Day12 do
  def find_the_answer_p1() do
    "data/day_12.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    state = %{
      board: input,
      regions: [],
      visited: [],
      current: %{
        x: 0,
        y: 0
      }
    }

    state =
      input
      |> Enum.reduce(state, fn {{x, y}, chr}, acc ->
        if %{x: x, y: y} in acc.visited do
          acc
        else
          {acc, trail} = dfs(%{acc | current: %{x: x, y: y}}, [])

          perimeter =
            trail
            |> Enum.reduce(0, fn %{x: x, y: y}, acc ->
              neightboors =
                [
                  {x + 1, y},
                  {x - 1, y},
                  {x, y + 1},
                  {x, y - 1}
                ]
                |> Enum.reject(fn {x, y} -> x < 0 or y < 0 end)
                |> Enum.reject(fn {x, y} -> %{x: x, y: y} not in trail end)

              perimeter = 4 - length(neightboors)

              acc + perimeter
            end)

          area = length(trail)

          price = area * perimeter

          new_regions = [
            %{
              char: chr,
              fields: trail,
              price: price,
              area: area,
              perimeter: perimeter
            }
            | acc.regions
          ]

          %{acc | regions: new_regions}
        end
      end)

    state.regions
    |> Enum.map(& &1.price)
    |> Enum.sum()
  end

  def dfs(state, trail) do
    current_char = state.board[{state.current.x, state.current.y}]
    state = %{state | visited: [state.current | state.visited]}
    trail = [state.current | trail]

    [
      {state.current.x + 1, state.current.y},
      {state.current.x - 1, state.current.y},
      {state.current.x, state.current.y + 1},
      {state.current.x, state.current.y - 1}
    ]
    |> Enum.reject(fn {x, y} -> x < 0 or y < 0 end)
    |> Enum.reject(fn {x, y} -> state.board[{x, y}] != current_char end)
    |> Enum.reduce({state, trail}, fn {next_x, next_y}, {acc, trail} ->
      if %{x: next_x, y: next_y} in acc.visited do
        {acc, trail}
      else
        dfs(%{acc | current: %{x: next_x, y: next_y}}, trail)
      end
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {chr, x} ->
        {{x, y}, chr}
      end)
    end)
    |> Enum.into(%{})
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
