defmodule FileDslTest do
  use ExUnit.Case

  test "handles file actions correctly" do
    # Create a temporary file for testing
    test_file = "test_file.txt"

    # Ensure the test file is removed after the test
    on_exit(fn -> File.rm(test_file) end)

    # Test writing to the file
    assert FileSystem.handle_file(test_file, :w, "Hello, World!") == :ok

    # Test reading from the file
    assert FileSystem.handle_file(test_file, :r) == "Hello, World!\n"

    # Test appending to the file
    assert FileSystem.handle_file(test_file, :a, "This is a test.") == :ok

    # Test reading the updated contents of the file
    assert FileSystem.handle_file(test_file, :r) == "Hello, World!\nThis is a test.\n"

    # Test deleting the file
    assert FileSystem.handle_file(test_file, :d) == :ok

    # Test reading from a non-existent file
    assert {:error, _} = FileSystem.handle_file(test_file, :r)

    # Test handling an invalid action flag
    assert {:error, _} = FileSystem.handle_file(test_file, :invalid_flag)
  end
end
