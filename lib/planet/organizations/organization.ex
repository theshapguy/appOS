defmodule Planet.Organizations.Organization do
  use Planet.Schema
  import Ecto.Changeset
  alias Planet.Organizations.OrganizationName

  schema "organizations" do
    field(:name, :string)
    field(:active?, :boolean, default: true, source: :is_active)
    field(:domain, :string)
    field(:subdomain, :string)

    has_many(:users, Planet.Accounts.User)

    has_many(:invited_organizations, Planet.Organizations.Organization,
      foreign_key: :invited_by_id
    )

    # Referred By
    belongs_to(:invited_by, Planet.Organizations.Organization)

    # Refer Code
    field(:refer_code, :binary_id)
    field(:timezone, :string)

    has_one(:subscription, Planet.Subscriptions.Subscription, foreign_key: :organization_id)
    has_many(:roles, Planet.Roles.Role)

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :timezone])
    |> validate_required([:name, :timezone])
  end

  @doc false
  def registration_changeset(organization, attrs) do
    organization
    |> cast(
      attrs,
      [
        :name,
        :active?,
        :invited_by_id,
        :timezone
        # :refer_code
      ]
    )
    |> generate_organization_name_changeset()
    |> generate_refer_code()
    |> validate_required([:name, :active?])
    |> unique_constraint(:name)
  end

  @doc """
  A timezone changeset for changing the timezone

  It requires the name to change otherwise an error is added.
  """
  def timezone_changeset(user, attrs) do
    user
    |> cast(attrs, [:timezone])
    |> validate_required([:timezone])
    |> validate_length(:name, max: 255)
    |> case do
      %{changes: %{timezone: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :timezone, "did not change")
    end
    |> validate_timezone()
  end

  def validate_timezone(changeset) do
    timezone = changeset |> get_field(:timezone)

    case Tzdata.zone_exists?(timezone) do
      false -> changeset |> add_error(:timezone, "timezone does not exist")
      true -> changeset
    end
  end

  defp generate_organization_name_changeset(changeset) do
    if changeset.valid? do
      changeset
      |> put_change(:name, generate_organization_name())
    else
      changeset
    end
  end

  ### Generate a random organization name from email
  defp generate_organization_name() do
    # [username | _] = String.split(email, "@", trim: true)
    organization_name = Enum.take_random(OrganizationName.word_list(), 2)

    Enum.join(organization_name, "—") <>
      "@" <>
      random_string_generator() <>
      " (autogenerated)"
  end

  defp generate_refer_code(changeset) do
    if changeset.valid? do
      changeset
      |> put_change(
        :refer_code,
        Ecto.UUID.generate()
      )
    else
      changeset
    end
  end

  defp random_string_generator(length \\ 4) do
    :crypto.strong_rand_bytes(length)
    |> Base.hex_encode32(padding: false, case: :lower)
    |> binary_part(0, length)
  end

  # defp get_username_from_email(email) do
  #   [username | _domain] = String.split(email, "@", trim: true)
  #   username
  # end
end
