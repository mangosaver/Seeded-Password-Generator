defmodule PassManager.SaltManager do
  use Agent

  def start_link(_opts) do
    salt = acquire_valid_salt()
    Agent.start_link(fn -> salt end, name: __MODULE__)
  end

  def get_salt(), do: Agent.get(__MODULE__, & &1)

  @doc """
  The main function for handling salt validity. If the salt cannot be read
  from a file, a new one will be generated and written. If the file contains
  a salt, it will be validated, and only overwritten if it is invalid.
  """
  defp acquire_valid_salt() do
    cached = read_salt()
    if cached == "" do
      write_new_salt()
    else
      if is_valid_salt(cached) do
        IO.puts("Salt read from priv/salt.txt")
        cached
      else
        write_new_salt()
      end
    end
  end

  @doc """
  Generates a new salt and stores it in priv/salt.txt.
  """
  defp write_new_salt() do
    IO.puts("Generating a new salt in priv/salt.txt...")
    fresh_salt = Bcrypt.Base.gen_salt(12, true)
    File.write("priv/salt.txt", fresh_salt)
    fresh_salt
  end

  @doc """
  Runs Bcrypt lib's hash_password/2 function to check if the salt is valid.
  A bit messy with the exception handling, but it works.
  """
  defp is_valid_salt(salt) do
    try do
      Bcrypt.Base.hash_password("test", salt)
      true
    rescue
      e in ArgumentError -> IO.puts("Salt validation error: " <> e.message)
      false
    end
  end

  @doc """
  Attempts to read the salt from priv/salt.txt, returns an empty string in the
  event of any error.
  """
  defp read_salt() do
    case File.read("priv/salt.txt") do
      {:ok, body} -> body
      {:error, :enoent} -> IO.puts("Error reading salt: file salt.txt does not exist")
      ""
      {:error, reason} -> IO.puts("Error reading salt file: #{reason}")
      _ -> IO.puts("Unknown error reading salt")
      ""
    end
  end
end
