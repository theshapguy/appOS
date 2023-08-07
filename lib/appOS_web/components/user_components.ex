defmodule AppOSWeb.UserComponents do
  import AppOSWeb.CoreComponents

  @moduledoc """
  Provides custom user UI components.

  """
  use Phoenix.Component
  use AppOSWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import AppOSWeb.Gettext

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
    doc: "Options as AppOS.Roles.Permissions (Nested List)"

  attr :selected_permissions, :list,
    default: [],
    doc: "Selected Options As Slug List In AppOS.Roles.Permissions"

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
              <div class="w-1/3 sm:w-1/2 font-medium"><%= permission_group.name %></div>
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
                        <div class="ml-2 select-none"><%= permission.name %></div>
                        <div class="ml-2 select-none text-xs text-zinc-500">
                          <%= permission.descriptor %>
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
      <%= @datetime
      |> Timex.Timezone.convert(@timezone)
      |> Timex.format!("{Mshort} {D}, {YYYY} {h12}:{m}{am}") %>
    </div>
    """
  end

  @doc """
  Renders navigation for landing pages

  """
  attr :current_user, :map, required: true

  def landing_navigation(assigns) do
    ~H"""
    <div x-data="{ open: false }" class="bg-[#100627]">
      <div class="max-w-4xl mx-auto px-4">
        <div class="flex items-center justify-between h-16">
          <!-- Logo -->
          <div class="flex-shrink-0 flex items-center">
            <!-- Replace 'logo.png' with your actual logo path -->
            <%!-- <img class="hidden h-8 w-auto" src="logo.png" alt="Logo" /> --%>

            <a href="/">
              <img class="block h-8 w-auto" src={~p"/images/logo.svg"} width="36" />
            </a>
          </div>
          <!-- Menu items -->
          <div class="sm:flex hidden justify-center flex-grow">
            <!-- Add your menu items here -->
        <!-- For example, you can add links to different pages -->
            <ul class="flex space-x-4">
              <li>
                <.link href={~p"/"} class="text-white px-3 py-2 rounded-md text-sm font-medium">
                  Home
                </.link>
              </li>
              <li>
                <a href="/plans" class="text-white px-3 py-2 rounded-md text-sm font-medium">
                  #Pricing - Link Not Working
                </a>
              </li>
            </ul>
          </div>
          <!-- Login and Signup buttons -->
          <%= if !@current_user do %>
            <div class="flex items-center gap-2">
              <.link
                href={~p"/users/log_in"}
                class="text-white px-3 py-2 rounded-md text-sm font-medium"
              >
                Log in
              </.link>

              <.link
                href={~p"/users/register"}
                class="text-#[485858] bg-[#B4DCDD] px-3 py-2 rounded-md text-sm font-medium"
              >
                Signup
              </.link>
            </div>
          <% else %>
            <div class="flex items-center gap-2">
              <.link
                href={~p"/users/settings"}
                class="text-white bg-teal-600 px-3 py-2 rounded-md text-sm font-medium"
              >
                Go To App <.icon name="hero-arrow-long-right" class="h-5 w-5" />
              </.link>
            </div>
          <% end %>
          <!-- Mobile menu toggle -->
          <div class="flex items-center sm:hidden">
            <button @click="open = !open" class="text-white p-2 rounded-md">
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16m-7 6h7"
                >
                </path>
              </svg>
            </button>
          </div>
        </div>
      </div>
      <!-- Mobile menu -->
      <div x-show="open" class="sm:hidden">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <!-- Add mobile version of menu items here -->
      <!-- For example, you can add links to different pages -->
          <.link href={~p"/"} class="text-white block px-3 py-2 rounded-md text-base font-medium">
            Home
          </.link>

          <a href="/plans" class="text-white block px-3 py-2 rounded-md text-base font-medium">
            #Pricing - Link Not Working
          </a>
        </div>
      </div>
    </div>
    """
  end
end
