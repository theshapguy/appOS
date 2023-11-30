# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PlanetRepo.insert!(%PlanetSomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
if Mix.env() == :dev do
  %Planet.Accounts.User{} =
    user =
    Planet.Accounts.register_user!(%{
      email: "seed@seed.com",
      password: "seed@seed.com"
    })

  {:ok, role} =
    Planet.Roles.create_role(
      user.organization,
      %{
        name: "Simple Seeded Role",
        permissions: ["settings-view", "settings-update"]
      }
    )

  Planet.Accounts.register_user_with_organization(user.organization, role, %{
    email: "member@seed.com",
    password: "member@seed.com"
  })

  Planet.Accounts.register_user_with_organization(user.organization, role, %{
    email: "member2@seed.com",
    password: "member2@seed.com"
  })

  %Planet.Accounts.User{} =
    user2 =
    Planet.Accounts.register_user!(%{
      email: "neupaneshapath@gmail.com",
      password: "neupaneshapath@gmail.com"
    })

  {:ok, role2} =
    Planet.Roles.create_role(
      user2.organization,
      %{
        name: "Simple Seeded Role",
        permissions: ["settings-view", "settings-update"]
      }
    )

  Planet.Accounts.register_user_with_organization(user2.organization, role2, %{
    email: "shapath@icloud.com",
    password: "shapath@icloud.com"
  })

  # Planet.Roles.create_role(user.organization, %{
  #   "name" => "Role",
  #   "permissions" => ["administrator-admin"],
  #   "editable?" => false
  # })
end
