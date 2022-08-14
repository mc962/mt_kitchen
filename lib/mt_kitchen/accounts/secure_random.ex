defmodule SecureRandom do
  @default_length 16

  def urlsafe_base64(length \\ @default_length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64
    |> binary_part(0, length)
  end
end