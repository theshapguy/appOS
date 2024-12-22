defmodule PlanetWeb.UserComponents do
  import PlanetWeb.CoreComponents

  @moduledoc """
  Provides custom user UI components.

  """
  use Phoenix.Component
  use PlanetWeb, :verified_routes

  import Planet.Helpers.ActiveLink, only: [active_path?: 2]

  # alias Phoenix.LiveView.JS
  # import PlanetWeb.Gettext

  def webauthn_arraybuffer_helpers(assigns) do
    ~H"""
    <script>
      function _arrayBufferToString(buffer) {
          var binary = '';
          var bytes = new Uint8Array(buffer);
          var len = bytes.byteLength;
          for (var i = 0; i < len; i++) {
              binary += String.fromCharCode(bytes[i]);
          }
          return binary;
      }

      function _arrayBufferToBase64(buffer) {
          var binary = '';
          var bytes = new Uint8Array(buffer);
          var len = bytes.byteLength;
          for (var i = 0; i < len; i++) {
              binary += String.fromCharCode(bytes[i]);
          }

          return window.btoa(binary);
      }

      function _base64ToArrayBuffer(base64) {
          var binary_string = window.atob(base64);
          var len = binary_string.length;
          var bytes = new Uint8Array(len);
          for (var i = 0; i < len; i++) {
              bytes[i] = binary_string.charCodeAt(i);
          }
          return bytes.buffer;
      }

      function base64RemovePadding(base64_string) {
          return base64_string.replace(/={1,2}$/, '');
      }

      function toggleErrorMessage(id, message, show) {

          var errorText = document.getElementById(id)

          if (show) {
              errorText.classList.remove("hidden")
              errorText.innerHTML = message
          } else {
              errorText.classList.add("hidden")
              errorText.innerHTML = ""
          }

      }

      function getDeviceDetails(ua) {
          if (ua) {
              ua = window.UAParser();
              return (ua.os.name + " — " + ua.browser.name).trim()
          } else {
              return "Unknown Device — " + Math.random().toString(36).substring(2, 7);
          }

      }
    </script>
    """
  end

  attr :id, :any

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :permission_groups, :list,
    required: true,
    doc: "Options as Planet.Roles.Permissions (Nested List)"

  attr :selected_permissions, :list,
    default: [],
    doc: "Selected Options As Slug List In Planet.Roles.Permissions"

  def permission_group_layout(assigns) do
    ~H"""
    <div class="flex flex-col gap-2.5">
      <%!--  Remove First Gap So No Margin--%>
      <div class="bg-white border border-gray-300 -mb-2.5">
        <div class="flex items-center bg-gray-200 py-2 px-4">
          <div class="w-1/3 sm:w-1/2 font-semibold">Roles</div>
          <div class="w-2/3 sm:w-1/2 font-semibold">Permissions</div>
        </div>
      </div>

      <%= for permission_group <- @permission_groups do %>
        <fieldset id={@field.id}>
          <div class="bg-white border border-gray-300">
            <div class="flex items-center py-2 px-4">
              <div class="w-1/3 sm:w-1/2 font-medium">{permission_group.name}</div>
              <div class="w-2/3 my-5 sm:w-1/2">
                <div class="space-y-5">
                  <%= for permission <- permission_group.permissions do %>
                    <label class="flex cursor-pointer" title={permission.descriptor}>
                      <input
                        type="checkbox"
                        name={"#{@field.name}[]"}
                        class="w-4 h-4 mt-1.5 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500"
                        value={permission.slug}
                        checked={permission.slug in @selected_permissions}
                      />
                      <div>
                        <div class="ml-2 select-none">{permission.name}</div>
                        <div class="ml-2 select-none text-xs text-zinc-500">
                          {permission.descriptor}
                        </div>
                      </div>
                    </label>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </fieldset>
      <% end %>
    </div>

    <script>
      function isAtLeastOneChecked(name) {
          let checkboxes = Array.from(document.getElementsByName(name));
          return checkboxes.some(e => e.checked);
      }
    </script>
    """
  end

  @doc """
  Renders a datetime with a specific timezone

  """
  attr :datetime, :string, required: true
  attr :timezone, :string, required: true

  def localtime(assigns) do
    ~H"""
    <div title={@datetime}>
      {@datetime
      |> Timex.Timezone.convert(@timezone)
      |> Timex.format!("{Mshort} {D}, {YYYY} {h12}:{m}{am}")}
    </div>
    """
  end

  @doc """
  Renders navigation for landing pages

  """
  attr :current_user, :map, required: true
  attr :conn, :any, required: true

  def landing_navigation(assigns) do
    ~H"""
    <nav class="fixed top-0 left-0 right-0 z-50 border-b border-neutral-200 bg-white/80 backdrop-blur-lg ">
      <div class="container max-w-5xl mx-auto flex items-center justify-between px-4 xl:px-0 py-3">
        <!-- Logo and App Name Section -->
        <div class="flex items-center">
          <.link
            href={~p"/"}
            class="text-xl font-bold text-neutral-900 hover:text-neutral-700 transition-colors"
          >
            {Application.get_env(:planet, Planet.Mailer)[:app_name]}
          </.link>
        </div>
        
    <!-- Desktop Navigation Links -->
        <div class="sm:flex items-center space-x-4 hidden" id="desktopNav">
          <.link
            href={~p"/plans"}
            class={[
              "text-sm font-medium  hover:text-blue-500 transition-colors",
              if(active_path?(@conn, to: ~p"/plans"), do: "text-blue-500", else: "text-neutral-600")
            ]}
          >
            Plans
          </.link>
          
    <!-- Login/Logout Toggle -->

          <%= if !@current_user do %>
            <.link
              href={~p"/users/log_in"}
              class={[
                "px-3 py-1.5 text-sm font-medium hover:text-blue-500 transition-colors",
                if(active_path?(@conn, to: ~p"/users/log_in"),
                  do: "text-blue-500",
                  else: "text-neutral-600"
                )
              ]}
            >
              Log in
            </.link>

            <.link
              href={~p"/users/register"}
              class="px-3 py-1.5 text-sm font-medium text-white bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 rounded-md transition-colors"
            >
              Signup
            </.link>
          <% else %>
            <.link
              href={~p"/app"}
              class="text-sm font-medium text-neutral-600 hover:text-blue-500 transition-colors"
            >
              Go To App <.icon name="hero-arrow-long-right" class="h-5 w-5" />
            </.link>
          <% end %>
        </div>
        
    <!-- Mobile Menu Toggle -->
        <div x-data="mobileMenu" @click.away="close($event)" class="sm:hidden flex items-center">
          <button
            id="mobileMenuToggle"
            @click="toggle"
            x-ref="toggle"
            class="text-neutral-600 hover:text-neutral-900 focus:outline-none"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 6h16M4 12h16M4 18h16"
              />
            </svg>
          </button>
        </div>
      </div>
      
    <!-- Mobile Menu Dropdown -->
      <div
        id="mobileMenu"
        x-show="open"
        x-ref="menu"
        class="sm:hidden absolute top-full left-0 right-0 bg-white shadow-lg hidden"
      >
        <div class="flex flex-col px-4 py-4 space-y-2">
          <.link
            href={~p"/plans"}
            class="text-sm font-medium text-neutral-600 hover:text-neutral-900 transition-colors py-2 border-b border-neutral-200"
          >
            Plans
          </.link>
          
    <!-- Mobile Login/Logout Toggle -->

          <%= if !@current_user do %>
            <.link
              href={~p"/users/log_in"}
              class="text-sm font-medium text-neutral-600 hover:text-neutral-900 transition-colors py-2 border-b border-neutral-200"
            >
              Log in
            </.link>

            <.link
              href={~p"/users/register"}
              class="text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors py-2 border-b border-neutral-200"
            >
              Signup
            </.link>
          <% else %>
            <.link
              href={~p"/app"}
              class="text-sm font-medium text-neutral-600 hover:text-blue-600 transition-colors py-2 border-b border-neutral-200"
            >
              Go To App <.icon name="hero-arrow-long-right" class="h-5 w-5" />
            </.link>
          <% end %>
        </div>
      </div>
    </nav>

    <.mobile_menu_toggle_script toggle_id="mobileMenuToggle" menu_div_id="mobileMenu" />
    """
  end

  @doc """
  Renders navigation for landing pages

  """
  attr :toggle_id, :any, required: true
  attr :menu_div_id, :any, required: true

  def mobile_menu_toggle_script(assigns) do
    ~H"""
    <script>
      // Mobile Menu Toggle
      const toggle = document.getElementById('<%= @toggle_id %>');
      const menu = document.getElementById('<%= @menu_div_id %>');

      toggle.addEventListener('click', () => menu.classList.toggle('hidden'));

      document.addEventListener('click', (event) => {
        if (!menu.contains(event.target) && !toggle.contains(event.target)) {
          menu.classList.add('hidden');
        }
      });
    </script>
    """
  end

  attr :license, Planet.Subscriptions.Subscription, doc: "subscription object", required: true
  attr :bank_statement, :string, required: true

  def billing_subtext_stripe(assigns) do
    ~H"""
    <% lifetime? =
      Planet.Payments.Plans.variant_by_price_id(@license.processor, @license.price_id).billing_frequency ==
        "once" %>

    <div :if={!lifetime?} class="text-zinc-400 text-sm my-5">
      <b>Your Next Payment</b>

      <p>
        Your next payment is scheduled for {Timex.format!(@license.valid_until, "{D} {Mfull} {YYYY}")}.
      </p>
    </div>

    <div :if={@license.transaction_history_url} class="text-zinc-400 text-sm my-5">
      <b>Manage Your Subscription</b>
      <p>
        To view your transaction history and manage your subscription,
        <a class="text-blue-500" href={@license.transaction_history_url} target="_blank">
          click here.
        </a>
      </p>
    </div>

    <div class="text-zinc-400 text-sm my-5">
      <b>Payment Processing</b>
      <p>
        All subscriptions and payments are securely processed by Stripe. Transactions will appear on your
        <span class="font-semibold">bank statement as {@bank_statement}.</span>
      </p>
    </div>
    """
  end

  attr :bank_statement, :string, required: true
  attr :license, Planet.Subscriptions.Subscription, doc: "subscription object", required: true

  def billing_subtext_paddle(assigns) do
    ~H"""
    <%!-- Only Show Subscription Actions When Not Lifetime Plan --%>

    <% lifetime? =
      Planet.Payments.Plans.variant_by_price_id(@license.processor, @license.price_id).billing_frequency ==
        "once" %>

    <div :if={!lifetime?} class="text-zinc-400 text-sm my-5">
      <b>Your Next Payment</b>

      <p>
        Your next payment is scheduled for {Timex.format!(@license.valid_until, "{D} {Mfull} {YYYY}")}.
      </p>
    </div>

    <div
      :if={@license.cancel_url != nil && @license.update_url != nil}
      class="text-zinc-400 text-sm my-5"
    >
      <b>Manage Your Subscription</b>

      <div :if={!lifetime?}>
        <p>
          To cancel your subscription, simply
          <a class="text-red-500" href={@license.cancel_url} target="_blank">
            click here.
          </a>
        </p>
        <p>
          To update your payment method, simply
          <a class="text-blue-500" href={@license.update_url} target="_blank">
            click here.
          </a>
        </p>

        <p>To upgrade or downgrade your plan, please contact us.</p>
      </div>

      <p>
        To view your entire transaction history here,
        <a class="text-blue-500" href={@license.transaction_history_url} target="_blank">
          click here.
        </a>
      </p>
    </div>

    <div class="text-zinc-400 text-sm my-5">
      <b>Payment Processing</b>
      <p>
        All subscriptions and payments are securely processed by our online reseller and Merchant of Record, Paddle.com. Transactions will appear on your
        <span class="font-semibold">bank statement as {@bank_statement}.</span>
      </p>
    </div>
    """
  end

  attr :bank_statement, :string, required: true
  attr :license, Planet.Subscriptions.Subscription, doc: "subscription object", required: true

  def billing_subtext_creem(assigns) do
    ~H"""
    <%!-- Only Show Subscription Actions When Not Lifetime Plan --%>
    <% lifetime? =
      Planet.Payments.Plans.variant_by_price_id(@license.processor, @license.price_id).billing_frequency ==
        "once" %>

    <div :if={!lifetime?} class="text-zinc-400 text-sm my-5">
      <b>Your Next Payment</b>

      <p>
        Your next payment is scheduled for {Timex.format!(@license.valid_until, "{D} {Mfull} {YYYY}")}.
      </p>
    </div>

    <div class="text-zinc-400 text-sm my-5">
      <b>Manage Your Subscription</b>

      <div :if={!lifetime? && @license.cancel_url != nil && @license.update_url != nil}>
        <p>
          To cancel your subscription, simply
          <a class="text-red-500" href={@license.cancel_url} target="_blank">
            click here.
          </a>
        </p>
        <p>
          To update your payment method, simply
          <a class="text-blue-500" href={@license.update_url} target="_blank">
            click here.
          </a>
        </p>

        <p>To upgrade or downgrade your plan, please contact us.</p>
      </div>

      <p>
        To view your entire transaction history here,
        <a class="text-blue-500" href={@license.transaction_history_url} target="_blank">
          click here.
        </a>
      </p>
    </div>

    <div class="text-zinc-400 text-sm my-5">
      <b>Payment Processing</b>
      <p>
        All subscriptions and payments are securely processed by our online reseller and Merchant of Record, Paddle.com. Transactions will appear on your
        <span class="font-semibold">bank statement as {@bank_statement}.</span>
      </p>
    </div>
    """
  end
end
