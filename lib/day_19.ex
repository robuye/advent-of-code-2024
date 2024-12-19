defmodule Day19 do
  def find_the_answer_p1() do
    "data/day_19.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1({towels, patterns}) do
    patterns
    |> Enum.map(fn pattern_str ->
      sort_towels(%{
        towels: Map.keys(towels),
        original_pattern: pattern_str,
        matched_patterns: [],
        queue: [{nil, pattern_str}]
      })
    end)
    |> Enum.filter(fn state -> state.original_pattern in state.matched_patterns end)
    |> length()
  end

  def sort_towels(state) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(state, fn
      _i, %{queue: []} = state ->
        {:halt, state}

      _i, state ->
        {{parents, current_pattern}, new_queue} = List.pop_at(state.queue, 0)

        next_candidates =
          state.towels
          |> Enum.filter(&String.starts_with?(current_pattern, &1))
          |> Enum.map(fn towel ->
            next_candidate = String.replace_prefix(current_pattern, towel, "")
            matched_fragment = "#{parents}#{towel}"

            {matched_fragment, next_candidate}
          end)

        next_queue = Enum.uniq(new_queue ++ next_candidates)

        state =
          sort_towels(%{
            state
            | queue: next_queue,
              matched_patterns:
                next_queue
                |> Enum.map(fn {matched_part, _rest} -> matched_part end)
                |> Enum.filter(&(&1 == state.original_pattern))
                |> Enum.concat(state.matched_patterns)
                |> Enum.uniq()
          })

        if state.original_pattern in state.matched_patterns do
          {:halt, state}
        else
          {:cont, state}
        end
    end)
  end

  def parse(input) do
    input
    |> String.split("\n\n")
    |> then(fn [towels_str, patterns_str] ->
      towels =
        Regex.scan(~r/\w+/, towels_str)
        |> List.flatten()
        |> Enum.map(fn x -> {x, true} end)
        |> Enum.into(%{})

      patterns =
        Regex.scan(~r/\w+/, patterns_str)
        |> List.flatten()

      {towels, patterns}
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
