defmodule Planet.OrganizationsTest do
  use Planet.DataCase

  import Planet.AccountsFixtures
  alias Planet.Organizations
  alias Planet.Organizations.Organization

  describe "get organizations" do
    test "get_organization!/1 returns the organization with given id" do
      user = user_fixture()

      assert Organizations.get_organization!(user.organization.id) ==
               user.organization
    end

    test "get_organization_by_refer_code/1 returns nil if refer code is nil" do
      assert nil == Organizations.get_organization_by_refer_code("")
    end

    test "get_organization_by_refer_code/1 returns organization with given invite code" do
      user = user_fixture()
      organization = user.organization
      refer_code = organization.refer_code

      assert organization == Organizations.get_organization_by_refer_code(refer_code)
    end
  end

  describe "update organizations" do
    test "update_organization/2 with valid data without refer code updates the organization" do
      user = user_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(user.organization, update_attrs)

      assert organization.name == "some updated name"
    end

    test "update_organization/2 with valid data updates the organization" do
      user = user_fixture()

      update_attrs = %{
        refer_code: "updated refer code",
        name: "some updated name"
      }

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(user.organization, update_attrs)

      assert organization.name == "some updated name"
      refute organization.refer_code == "updated refer code"
      assert organization.refer_code == user.organization.refer_code
    end

    test "update_organization/2 with invalid data returns error changeset" do
      user = user_fixture()

      invalid_attrs = %{
        refer_code: nil,
        name: nil
      }

      assert {:error, %Ecto.Changeset{}} =
               Organizations.update_organization(user.organization, invalid_attrs)

      assert user.organization ==
               Organizations.get_organization!(user.organization.id)
    end
  end

  describe "organization changesets" do
    test "change_organization/1 returns a changeset" do
      user = user_fixture()
      organization = user.organization

      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end

    test "change_organization_for_registration/1 returns a changeset" do
      user = user_fixture()
      organization = user.organization

      assert %Ecto.Changeset{} = Organizations.change_organization_for_registration(organization)
    end
  end
end
