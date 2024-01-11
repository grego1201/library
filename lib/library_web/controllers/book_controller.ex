defmodule LibraryWeb.BookController do
  use LibraryWeb, :controller

  alias Library.Books
  alias Library.Books.Book

  def index(conn, _params) do
    books = Books.list_books()
    render(conn, :index, books: books)
  end

  def new(conn, _params) do
    changeset = Books.change_book(%Book{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"book" => book_params}) do
    new_book_params = if upload = book_params["photo"] do
      parsed_params = Map.delete(book_params, "photo")
      {:ok, cover_image_path} = Books.save_cover(upload, book_params["isbn"])
      Map.merge(parsed_params, %{"cover_image_path" => cover_image_path})
    else
      Map.delete(book_params, "photo")
    end

    new_book_params = Map.update!(new_book_params, "publisher_id", fn publisher_id -> String.to_integer(publisher_id) end)
    case Books.create_book(new_book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book created successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    render(conn, :show, book: book)
  end

  def edit(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    changeset = Books.change_book(book)
    render(conn, :edit, book: book, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Books.get_book!(id)

    new_book_params = if upload = book_params["photo"] do
      parsed_params = Map.delete(book_params, "photo")
      {:ok, cover_image_path} = Books.save_cover(upload, book_params["isbn"])
      Map.merge(parsed_params, %{"cover_image_path" => cover_image_path})
    else
      Map.delete(book_params, "photo")
    end

    case Books.update_book(book, new_book_params) do
      {:ok, book} ->
        conn
        |> put_flash(:info, "Book updated successfully.")
        |> redirect(to: ~p"/books/#{book}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, book: book, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Books.get_book!(id)
    {:ok, _book} = Books.delete_book(book)

    conn
    |> put_flash(:info, "Book deleted successfully.")
    |> redirect(to: ~p"/books")
  end
end
