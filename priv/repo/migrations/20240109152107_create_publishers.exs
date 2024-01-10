defmodule Library.Repo.Migrations.CreatePublishers do
  use Ecto.Migration

  def change do
    create table(:publishers) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
