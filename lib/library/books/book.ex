defmodule Library.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  alias Library.Editorial.Publisher

  schema "books" do
    field :title, :string
    field :isbn, :string
    field :cover_image_path, :string

    belongs_to(:publisher, Publisher)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :isbn, :cover_image_path, :publisher_id])
    |> validate_required([:title, :isbn, :cover_image_path, :publisher_id])
    |> unique_constraint(:cover_image_path)
    |> unique_constraint(:isbn)
    |> unique_constraint(:title)
  end
end
