defmodule Library.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :isbn, :string
      add :cover_image_path, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:books, [:cover_image_path])
    create unique_index(:books, [:isbn])
    create unique_index(:books, [:title])
  end
end
