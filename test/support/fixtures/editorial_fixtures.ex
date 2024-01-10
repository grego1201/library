defmodule Library.EditorialFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Library.Editorial` context.
  """

  @doc """
  Generate a publisher.
  """
  def publisher_fixture(attrs \\ %{}) do
    {:ok, publisher} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Library.Editorial.create_publisher()

    publisher
  end

  @doc """
  Generate a unique book cover_image_path.
  """
  def unique_book_cover_image_path, do: "some cover_image_path#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique book isbn.
  """
  def unique_book_isbn, do: "some isbn#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique book title.
  """
  def unique_book_title, do: "some title#{System.unique_integer([:positive])}"

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        cover_image_path: unique_book_cover_image_path(),
        isbn: unique_book_isbn(),
        title: unique_book_title()
      })
      |> Library.Editorial.create_book()

    book
  end
end
