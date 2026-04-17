defmodule FileSystem do
  use FileDSL

  file_action(:read, :r, :read_file)
  file_action(:write, :w, :write_to_file)
  file_action(:append, :a, :append_to_file)
  file_action(:delete, :d, :delete_file)

  # The read_file function will read the entire contents of the file and return it as a string. If the file does not exist or cannot be read, it will return an error message.
  def read_file(file_path) do
    IO.puts("Reading from #{file_path}")
    # Open the file in read mode
    file_handle = File.open(file_path, [:read])

    case file_handle do
      {:ok, file} ->
        #
        content = IO.read(file, :eof)
        File.close(file)
        content

      {:error, reason} ->
        handle_file_error(reason, file_path)
    end
  end

  # The write_to_file function will create the file if it doesn't exist, or overwrite it if it does.
  def write_to_file(file_path, text) do
    IO.puts("Writing to #{file_path}")
    # This will create the file if it doesn't exist, or overwrite it if it does
    file_handle = File.open(file_path, [:write])

    case file_handle do
      {:ok, file} ->
        IO.write(file, "#{text}\n")
        File.close(file)
        :ok

      {:error, reason} ->
        handle_file_error(reason, file_path)
    end
  end

  # The append_to_file function will create the file if it doesn't exist, or append to it if it does.
  def append_to_file(file_path, text) do
    IO.puts("Appending to #{file_path}")
    # Open the file in append mode
    file_handle = File.open(file_path, [:append])

    case file_handle do
      {:ok, file} ->
        IO.write(file, "#{text}\n")
        File.close(file)
        :ok

      {:error, reason} ->
        handle_file_error(reason, file_path)
    end
  end

  # The delete_file function will attempt to delete the specified file. If the file does not exist or cannot be deleted, it will return an error message.
  def delete_file(file_path) do
    IO.puts("Deleting #{file_path}")

    case File.rm(file_path) do
      :ok -> :ok
      {:error, reason} -> handle_file_error(reason, file_path)
    end
  end

  # Helper function to handle file errors
  defp handle_file_error(reason, file_path) do
    case reason do
      :enoent -> {:error, "File not found: #{file_path}"}
      :eacces -> {:error, "Permission denied: #{file_path}"}
      :eisdir -> {:error, "Is a directory: #{file_path}"}
      _ -> {:error, "File operation failed: #{reason}"}
    end
  end
end
