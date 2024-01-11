defmodule Library.Books do
  @moduledoc """
  The Editorial context.
  """

  import Ecto.Query, warn: false
  alias Library.Repo

  alias Library.Books.Book

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book) |> Repo.preload(:publisher)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id) |> Repo.preload(:publisher)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end


  @doc """
  Returns a tuple `{:ok, path}` in case that cover have been saved.
  Returns a tuple `{:error, reason}` in case that cover can not been saved.

  ## Examples
    iex> save_cover(upload, isbn)
    {:ok, "path_to_cover"}
  """
  def save_cover(%Plug.Upload{} = upload, isbn) do
    extension = Path.extname(upload.filename)
    new_path = "priv/static/images/cover_images/#{isbn}-cover#{extension}"
    case File.cp(upload.path, new_path) do
      :ok -> {:ok, new_path}
      {:error, reason} -> {:error, reason}
    end
  end
end
