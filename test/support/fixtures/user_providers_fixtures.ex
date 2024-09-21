defmodule Planet.UserProvidersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planet.UserProviders` context.
  """
  alias Planet.Accounts.User

  @doc """
  Generate a user_provider.
  """
  def user_provider_fixture(%User{} = user, attrs \\ %{}) do
    {:ok, user_provider} =
      attrs
      |> Enum.into(%{
        object: %{},
        provider: "some provider",
        token: "some token",
        user_id: user.id
      })
      |> Planet.UserProviders.create_user_provider()

    user_provider
  end

  def ueberauthn_auth_fixture(_attrs \\ %{}) do
    %Ueberauth.Auth{
      uid: "100156885102934590394",
      provider: :google,
      strategy: Ueberauth.Strategy.Google,
      info: %Ueberauth.Auth.Info{
        name: nil,
        first_name: nil,
        last_name: nil,
        nickname: nil,
        email: "neupaneshapath@gmail.com",
        location: nil,
        description: nil,
        image:
          "https://lh3.googleusercontent.com/a-/ALV-UjWWV51ViQr1OVAweBCw91UPZJS2pvnjXvgy1FjeM4IRc7f4ynRI=s96-c",
        phone: nil,
        birthday: nil,
        urls: %{profile: nil, website: nil}
      },
      credentials: %Ueberauth.Auth.Credentials{
        token:
          "ya29.a0AcM612zMsz09fcWSCK8_My7GL43qWTvuNUnLwZKwEWnESKnpUQI4bN2FOUt9QubNqwEfxyNcF1D5_rhoaiFSRv2Up6cPYZ4CXK0pXkF3016PwgqKD-Byv4FVnzfzznh3ewUwvWI673irJBhD55nti36ijFcyxNWcaAIaCgYKAd4SARESFQHGX2MiTbXBuX1jCmrnZYq82Rd7jA0170",
        refresh_token: nil,
        token_type: "Bearer",
        secret: nil,
        expires: true,
        expires_at: 1_726_925_566,
        scopes: ["openid", "https://www.googleapis.com/auth/userinfo.email"],
        other: %{}
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          user: %{
            "email" => "neupaneshapath@gmail.com",
            "email_verified" => true,
            "picture" =>
              "https://lh3.googleusercontent.com/a-/ALV-UjWWV51ViQr1OVAweBCw91UPZJS2pvnjXvgy1FjeM4IRc7f4ynRI=s96-c",
            "sub" => "100156885102934590394"
          },
          token: %OAuth2.AccessToken{
            access_token:
              "ya29.a0AcM612zMsz09fcWSCK8_My7GL43qWTvuNUnLwZKwEWnESKnpUQI4bN2FOUt9QubNqwEfxyNcF1D5_rhoaiFSRv2Up6cPYZ4CXK0pXkF3016PwgqKD-Byv4FVnzfzznh3ewUwvWI673irJBhD55nti36ijFcyxNWcaAIaCgYKAd4SARESFQHGX2MiTbXBuX1jCmrnZYq82Rd7jA0170",
            refresh_token: nil,
            expires_at: 1_726_925_566,
            token_type: "Bearer",
            other_params: %{
              "id_token" =>
                "eyJhbGciOiJSUzI1NiIsImtpZCI6ImIyNjIwZDVlN2YxMzJiNTJhZmU4ODc1Y2RmMzc3NmMwNjQyNDlkMDQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyOTE0MjYzMTM2NzgtZTlob3FmOWU4NmNtc3VqNzJwZHFkb2tkdWdvYWVsMG8uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyOTE0MjYzMTM2NzgtZTlob3FmOWU4NmNtc3VqNzJwZHFkb2tkdWdvYWVsMG8uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDAxNTY4ODUxMDI5MzQ1OTAzOTQiLCJlbWFpbCI6Im5ldXBhbmVzaGFwYXRoQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoiSXI3Y2RnR19tT0JOUkxEQmVyTWVXZyIsImlhdCI6MTcyNjkyMTk2NywiZXhwIjoxNzI2OTI1NTY3fQ.U7Ihi6TBoMQn-8EIjMT866DWgN3peMlXz_zJRKQ2rumvoghox7CcUUcW6fCiJ01udcX2szhJA8pv04ngs-gufkFbYSVXu-ZOnoPV_lMiIKIkPrMvgyNbmF4nOiWMOEovc-VcSUw9SiLjaKS7YHW1NPe9IH9tgdxnzSiPEspQrcg2RRaaffIxzZoZmNc-mNtSSdjpCHOWej9hudmQgNH3SW67vyWCA-8VpJYpoRn_3B5b1pu_LRSCklMuP_BX_97evIu4y4mCSuJ4L6kWEce9kapNwKYv9Yhs_yH7fBT3GDsjQwFrXa8V2GHRhwuBTaWsDswohjFJyyl4AAmw1EtGGA",
              "scope" => "openid https://www.googleapis.com/auth/userinfo.email"
            }
          }
        }
      }
    }
  end
end
