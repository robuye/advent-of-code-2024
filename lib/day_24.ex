defmodule Day24 do
  def find_the_answer_p1() do
    "data/day_24.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    activate(input)
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "z") end)
    |> Enum.sort_by(fn {k, _v} -> k end, :desc)
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  def activate(%{gates: []} = state), do: state.wires

  def activate(state) do
    {next_gate, gates_left} = List.pop_at(state.gates, 0)

    a = state.wires[next_gate.input.a]
    b = state.wires[next_gate.input.b]

    if is_nil(a) or is_nil(b) do
      activate(%{state | gates: gates_left ++ [next_gate]})
    else
      result =
        case next_gate.op do
          "AND" -> if(a + b == 2, do: 1, else: 0)
          "OR" -> if(a + b > 0, do: 1, else: 0)
          "XOR" -> if(a + b == 1, do: 1, else: 0)
        end

      new_wires =
        state.wires
        |> Map.put(next_gate.out, result)

      activate(%{state | wires: new_wires, gates: gates_left})
    end
  end

  def parse(input) do
    [wires_str, gates_str] =
      input
      |> String.split("\n\n")

    wires =
      wires_str
      |> String.split("\n")
      |> Enum.map(fn wire_str ->
        [key, val] =
          wire_str
          |> String.split(":", trim: true)

        val =
          val
          |> String.trim()
          |> String.to_integer()

        {key, val}
      end)
      |> Enum.into(%{})

    gates =
      gates_str
      |> String.split("\n", trim: true)
      |> Enum.map(fn gate_str ->
        [a, op, b, out] =
          ~r/(\w+) (\w+) (\w+) -> (\w+)/
          |> Regex.run(gate_str, capture: :all_but_first)

        %{input: %{a: a, b: b}, op: op, out: out}
      end)

    %{wires: wires, gates: gates}
  end

  def read_the_input(path), do: File.read!(path)
end
