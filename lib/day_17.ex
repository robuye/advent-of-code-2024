defmodule Day17 do
  def find_the_answer_p1() do
    "data/day_17.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(state) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(state, fn _i, state ->
      if Enum.at(state.program, state.step) do
        [opcode, operand] = Enum.slice(state.program, state.step, 2)
        {:cont, execute_instruction(state, opcode, operand)}
      else
        {:halt, state}
      end
    end)
    |> then(fn state ->
      state.out
      |> Enum.reverse()
      |> Enum.join(",")
      |> IO.puts()
    end)

    :ok
  end

  # adv, division
  def execute_instruction(state, 0, operand) do
    numerator = state.a
    denominator = Integer.pow(2, get_combo_value(state, operand))

    result = div(numerator, denominator)

    IO.puts("PC[#{state.step}] execute ADV(0) with #{operand}, result: #{result}")
    %{state | a: result, step: state.step + 2}
  end

  # bxl, xor
  def execute_instruction(state, 1, operand) do
    result = Bitwise.bxor(state.b, operand)

    IO.puts("PC[#{state.step}] execute BXL(1) with #{operand} result: #{result}")
    %{state | b: result, step: state.step + 2}
  end

  # bst
  def execute_instruction(state, 2, operand) do
    result = Integer.mod(get_combo_value(state, operand), 8)
    IO.puts("PC[#{state.step}] execute BST(2) with #{operand} result: #{result}")
    %{state | b: result, step: state.step + 2}
  end

  # jnz
  def execute_instruction(state, 3, operand) do
    if state.a == 0 do
      IO.puts("PC[#{state.step}] execute JNZ(3) with #{operand}. Do nothing because A == 0.")
      %{state | step: state.step + 2}
    else
      IO.puts("PC[#{state.step}] execute JNZ(3) with #{operand}. Jump to #{operand}.")
      %{state | step: operand}
    end
  end

  # bxc
  def execute_instruction(state, 4, operand) do
    result = Bitwise.bxor(state.b, state.c)

    IO.puts("PC[#{state.step}] execute BXC(4) with #{operand} result: #{result}")
    %{state | step: state.step + 2, b: result}
  end

  # out
  def execute_instruction(state, 5, operand) do
    result = Integer.mod(get_combo_value(state, operand), 8)

    IO.puts("PC[#{state.step}] execute OUT(5) with #{operand} result: #{result}")
    %{state | step: state.step + 2, out: [result | state.out]}
  end

  # bdv
  def execute_instruction(state, 6, operand) do
    numerator = state.a
    denominator = Integer.pow(2, get_combo_value(state, operand))

    result = div(numerator, denominator)

    IO.puts("PC[#{state.step}] execute BDV(6) with #{operand} result: #{result}")
    %{state | b: result, step: state.step + 2}
  end

  # cdv
  def execute_instruction(state, 7, operand) do
    numerator = state.a
    denominator = Integer.pow(2, get_combo_value(state, operand))

    result = div(numerator, denominator)

    IO.puts("PC[#{state.step}] execute CDV(6) with #{operand} result: #{result}")
    %{state | c: result, step: state.step + 2}
  end

  def parse(input) do
    [registers_str, instructions_str] =
      String.split(input, "\n\n")

    [a, b, c] =
      Regex.scan(~r/\d+/, registers_str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    instructions =
      Regex.scan(~r/\d/, instructions_str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    %{a: a, b: b, c: c, program: instructions, step: 0, out: []}
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end

  defp get_combo_value(state, 4), do: state.a
  defp get_combo_value(state, 5), do: state.b
  defp get_combo_value(state, 6), do: state.c
  defp get_combo_value(_state, v) when v in 0..3, do: v
end
