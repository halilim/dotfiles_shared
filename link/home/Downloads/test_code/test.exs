# IO.inspect (1..10) |> Enum.reduce([0, 1], fn (_n, acc) -> acc ++ [Enum.slice(acc, (Enum.count(acc)-2)..-1) |> Enum.reduce(&+/2)] end)
IO.inspect((1..10)
# |> Enum.reduce([0, 1], fn (_n, acc) ->
#   [acc |> Enum.slice(Enum.count(acc)-2..-1) |> Enum.reduce(&+/2)|Enum.reverse(acc)] |> Enum.reverse
# end))
