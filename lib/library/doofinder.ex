defmodule Library.Doofinder do
  @moduledoc """
  The Editorial context.
  """

  alias Library.Books

  @books_feed_headers [brand: :brand, group_id: :group_id, id: :id, cover_image_link: :cover_image_link, link: :link, title: :title]
  @books_feed_path "priv/static/feed_data/feed_data.csv"

  def generate_books_feed() do
    file = File.open!(@books_feed_path, [:write])
    write_books_feed_body(file)
  end

  defp write_books_feed_body(file) do
    books = Books.list_books
    mapped_books = Enum.map(books, fn book -> book_to_row(book) end)
    csv_content = mapped_books |> CSV.encode(headers: @books_feed_headers) |> Enum.to_list()
    IO.puts(file, csv_content)
  end

  defp book_to_row(book) do
    %{
      brand: book.publisher.name,
      group_id: book.publisher.id,
      id: book.id,
      cover_image_link: book.cover_image_path,
      link: "https://foo.com",
      title: book.title,
    }
  end
end
