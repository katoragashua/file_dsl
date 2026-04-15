defmodule MyFile do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :file_actions, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_file(file_path, flag, text \\ nil) do
        # IO.inspect(@file_actions)
          desired_action = Enum.find(@file_actions, nil, fn {_, action_flag, _} -> flag == action_flag end)
          #  desired_action = Enum.find_value(@file_actions, nil, fn {_, action_flag, action_func} -> if flag == action_flag, do: action_func, else: nil end)
          # desired_action =
          # Enum.find_value(@file_actions, fn {_, action_flag, action_func} ->
          #   flag == action_flag && action_func
          # end) || nil

          # IO.inspect(desired_action)
          case desired_action do
            {_action_name, _action_flag, action_func} -> apply(__MODULE__, action_func, [file_path, text])
            nil -> {:error, "Invalid action flag: #{flag}"}
          end
      end
    end
  end

  defmacro file_action(action_name, action_flag, action_func) do
    quote do: @file_actions {unquote(action_name), unquote(action_flag), unquote(action_func)}
  end
end


defmodule FileSystem do
  use MyFile

  file_action :read, :r, :read_file
  file_action :write, :w, :write_to_file
  file_action :append, :a, :append_to_file
  file_action :delete, :d, :delete_file

  def read_file(file_path, _text) do
    IO.puts("Reading from #{file_path}")
   file_handle = File.open(file_path, [:read]) # Open the file in read mode
   case file_handle do
    {:ok, file} ->
      content = IO.read(file, :eof) #
      File.close(file)
      content
    {:error, reason} ->
      handle_file_error(reason, file_path)
   end

  end

  def write_to_file(file_path, text) do
    IO.puts("Writing to #{file_path}")
    file_handle = File.open(file_path, [:write]) # This will create the file if it doesn't exist, or overwrite it if it does
    case file_handle do
      {:ok, file} ->
        IO.write(file, "#{text}\n")
        File.close(file)
        :ok
      {:error, reason} ->
        handle_file_error(reason, file_path)
    end
  end

  def append_to_file(file_path, text) do
    IO.puts("Appending to #{file_path}")
    file_handle = File.open(file_path, [:append]) # Open the file in append mode
    case file_handle do
      {:ok, file} ->
        IO.write(file, "#{text}\n")
        File.close(file)
        :ok
      {:error, reason} ->
        handle_file_error(reason, file_path)
    end
  end

  def delete_file(file_path, _text) do
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
