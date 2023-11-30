defmodule Planet.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planet,Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def valid_organization_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Planet.Accounts.register_user()

    user
  end

  def user_fixture(
        %Planet.Organizations.Organization{} = organization,
        %Planet.Roles.Role{} = role,
        attrs \\ %{}
      ) do
    attrs =
      attrs
      |> valid_user_attributes()

    {:ok, user} = Planet.Accounts.register_user_with_organization(organization, role, attrs)

    user
  end

  def organization_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Planet.Accounts.register_user()

    user.organization
  end

  def user_credential_fixture(%Planet.Accounts.User{} = user) do
    unique_data = unique_user_email()

    {:ok, credential} =
      Planet.UserCredentials.create_user_credentail(
        user,
        %{
          "credential_id" => unique_data,
          "credential_public_key" => %{
            -3 =>
              <<68, 67, 73, 181, 217, 111, 86, 195, 55, 197, 189, 186, 143, 59, 162, 92, 73, 34,
                0, 145, 105, 78, 91, 39, 38, 36, 49, 191, 247, 106, 8, 37>>,
            -2 =>
              <<207, 83, 68, 234, 182, 221, 210, 242, 248, 48, 60, 125, 63, 68, 136, 152, 240,
                108, 15, 241, 110, 111, 127, 33, 146, 166, 6, 128, 159, 234, 48, 160>>,
            -1 => 1,
            1 => 2,
            3 => -7
          },
          "aaguid" => Ecto.UUID.generate(),
          "nickname" => unique_data
        }
      )

    credential
  end

  def wax_authentication_data_fixture() do
    %Wax.AuthenticatorData{
      rp_id_hash:
        <<126, 106, 62, 157, 108, 120, 148, 121, 196, 13, 5, 240, 249, 223, 169, 31, 139, 118,
          180, 241, 120, 31, 94, 118, 46, 15, 145, 9, 97, 158, 251, 155>>,
      flag_user_present: true,
      flag_user_verified: true,
      flag_backup_eligible: true,
      flag_credential_backed_up: true,
      flag_attested_credential_data: true,
      flag_extension_data_included: false,
      sign_count: 0,
      attested_credential_data: %Wax.AttestedCredentialData{
        aaguid: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
        credential_id:
          <<175, 145, 48, 63, 105, 93, 104, 57, 169, 43, 196, 241, 211, 180, 103, 202, 62, 251,
            124, 169>>,
        credential_public_key: %{
          -3 =>
            <<187, 3, 15, 51, 4, 72, 243, 75, 149, 158, 35, 211, 43, 119, 186, 143, 186, 221, 98,
              28, 225, 123, 181, 120, 213, 124, 65, 53, 160, 136, 59, 111>>,
          -2 =>
            <<1, 84, 168, 218, 170, 174, 217, 37, 11, 115, 219, 85, 88, 82, 89, 149, 230, 68, 42,
              156, 5, 59, 65, 223, 229, 139, 131, 19, 90, 249, 195, 3>>,
          -1 => 1,
          1 => 2,
          3 => -7
        }
      },
      extensions: nil,
      raw_bytes:
        <<126, 106, 62, 157, 108, 120, 148, 121, 196, 13, 5, 240, 249, 223, 169, 31, 139, 118,
          180, 241, 120, 31, 94, 118, 46, 15, 145, 9, 97, 158, 251, 155, 93, 0, 0, 0, 0, 0, 0>>
    }
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
