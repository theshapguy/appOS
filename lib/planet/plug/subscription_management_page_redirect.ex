defmodule Planet.Plug.SubscriptionManagementRedirect do
  import Plug.Conn
  import Phoenix.Controller
  alias Planet.Payments.Plans

  def init(opts) do
    opts
  end

  def call(
        %{
          path_info: ["users", "billing", "signup"],
          params: %{"lifetime" => "yes"}
        } = conn,
        _opts
      ) do
    subscription = conn.assigns.current_user.organization.subscription

    # %{billing_frequency: frequency} =
    plan = Plans.variant_by_price_id(subscription.processor, subscription.price_id)

    case subscription.subscription_id do
      nil ->
        # If Nil, Remove Lifetime only Option
        conn
        |> redirect(to: "/users/billing/signup")
        |> halt()

      _ ->
        if Map.get(plan, :billing_frequency) != "once" do
          conn
        else
          conn
          |> redirect(to: "/users/billing/")
          |> halt()
        end
    end
  end

  def call(
        %{
          path_info: ["users", "billing", "signup"]
        } = conn,
        _opts
      ) do
    subscription = conn.assigns.current_user.organization.subscription

    case subscription.subscription_id do
      nil ->
        conn

      _ ->
        conn
        |> redirect(to: "/users/billing/")
        |> halt()
    end
  end

  def call(
        %{
          path_info: ["users", "billing"]
        } = conn,
        _opts
      ) do
    subscription = conn.assigns.current_user.organization.subscription

    case subscription.subscription_id do
      nil ->
        conn
        |> redirect(to: "/users/billing/signup")
        |> halt()

      _ ->
        conn
    end
  end
end
