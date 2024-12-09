defmodule Day09 do
  def find_the_answer_p1() do
    "data/day_09.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    input_len = length(input)

    input
    |> Enum.with_index()
    |> Enum.reduce_while({input_len - 1, input}, fn
      {".", idx}, {cursor_idx, results} ->
        {cursor_idx, replacement} = find_replacement(cursor_idx, results)

        results =
          results
          |> List.replace_at(idx, replacement)
          |> List.replace_at(cursor_idx, ".")

        {:cont, {cursor_idx - 1, results}}

      {_, idx}, {cursor_idx, results} when cursor_idx <= idx ->
        {:halt, {cursor_idx, results}}

      _, {cursor, results} ->
        {:cont, {cursor, results}}
    end)
    |> elem(1)
    |> Enum.with_index()
    |> Enum.reduce_while(0, fn
      {".", _idx}, sum -> {:halt, sum}
      {file_id, idx}, sum -> {:cont, sum + idx * file_id}
    end)
  end

  defp find_replacement(cursor_idx, results) do
    results
    |> Enum.at(cursor_idx)
    |> case do
      "." -> find_replacement(cursor_idx - 1, results)
      file_id -> {cursor_idx, file_id}
    end
  end

  def parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.reduce({0, []}, fn
      [0, 0], acc ->
        acc

      [files, free_space], {next_id, results} when files > 0 and free_space > 0 ->
        allocated_files = Enum.map(1..files, fn _ -> next_id end)
        allocated_space = Enum.map(1..free_space, fn _ -> "." end)
        {next_id + 1, results ++ allocated_files ++ allocated_space}

      [0, free_space], {next_id, results} when free_space > 0 ->
        allocated_space = Enum.map(1..free_space, fn _ -> "." end)
        {next_id, results ++ allocated_space}

      [files, 0], {next_id, results} when files > 0 ->
        allocated_files = Enum.map(1..files, fn _ -> next_id end)
        {next_id + 1, results ++ allocated_files}

      [files], {next_id, results} when files > 0 ->
        allocated_files = Enum.map(1..files, fn _ -> next_id end)
        {next_id + 1, results ++ allocated_files}

      _, acc ->
        acc
    end)
    |> elem(1)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
