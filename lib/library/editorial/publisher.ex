defmodule Library.Editorial.Publisher do
  use Ecto.Schema
  import Ecto.Changeset

  alias Library.Editorial.Book

  schema "publishers" do
    field :name, :string

    has_many :books, Book

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(publisher, attrs) do
    publisher
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
