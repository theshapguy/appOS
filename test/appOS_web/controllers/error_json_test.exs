defmodule AppOSWeb.ErrorJSONTest do
  use AppOSWeb.ConnCase, async: true

  test "renders 404" do
    assert AppOSWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AppOSWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
