defmodule LibraryWeb.BookHTML do
  use LibraryWeb, :html

  embed_templates "book_html/*"

  @doc """
  Renders a book form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def book_form(assigns)

  def publisher_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:publisher_ids, [])
      |> Enum.map(& &1.data.id)

    for publisher <- Library.Editorial.list_publishers(),
      do: [key: publisher.name, value: publisher.id, selected: publisher.id in existing_ids]
  end

  def cover_path(%Library.Books.Book{} = book) do
    String.replace(book.cover_image_path, "priv/static", "")
  end
end
