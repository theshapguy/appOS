defmodule PlanetWeb.DummyLiveTest do
  use PlanetWeb.ConnCase

  import Phoenix.LiveViewTest
  import Planet.DummiesFixtures

  @create_attrs %{name: "some name", age: 42}
  @update_attrs %{name: "some updated name", age: 43}
  @invalid_attrs %{name: nil, age: nil}

  defp create_dummy(_) do
    dummy = dummy_fixture()
    %{dummy: dummy}
  end

  describe "Index" do
    setup [:create_dummy]

    test "lists all dummies", %{conn: conn, dummy: dummy} do
      {:ok, _index_live, html} = live(conn, ~p"/dummies")

      assert html =~ "Listing Dummies"
      assert html =~ dummy.name
    end

    test "saves new dummy", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/dummies")

      assert index_live |> element("a", "New Dummy") |> render_click() =~
               "New Dummy"

      assert_patch(index_live, ~p"/dummies/new")

      assert index_live
             |> form("#dummy-form", dummy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#dummy-form", dummy: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/dummies")

      html = render(index_live)
      assert html =~ "Dummy created successfully"
      assert html =~ "some name"
    end

    test "updates dummy in listing", %{conn: conn, dummy: dummy} do
      {:ok, index_live, _html} = live(conn, ~p"/dummies")

      assert index_live |> element("#dummies-#{dummy.id} a", "Edit") |> render_click() =~
               "Edit Dummy"

      assert_patch(index_live, ~p"/dummies/#{dummy}/edit")

      assert index_live
             |> form("#dummy-form", dummy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#dummy-form", dummy: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/dummies")

      html = render(index_live)
      assert html =~ "Dummy updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes dummy in listing", %{conn: conn, dummy: dummy} do
      {:ok, index_live, _html} = live(conn, ~p"/dummies")

      assert index_live |> element("#dummies-#{dummy.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#dummies-#{dummy.id}")
    end
  end

  describe "Show" do
    setup [:create_dummy]

    test "displays dummy", %{conn: conn, dummy: dummy} do
      {:ok, _show_live, html} = live(conn, ~p"/dummies/#{dummy}")

      assert html =~ "Show Dummy"
      assert html =~ dummy.name
    end

    test "updates dummy within modal", %{conn: conn, dummy: dummy} do
      {:ok, show_live, _html} = live(conn, ~p"/dummies/#{dummy}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Dummy"

      assert_patch(show_live, ~p"/dummies/#{dummy}/show/edit")

      assert show_live
             |> form("#dummy-form", dummy: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#dummy-form", dummy: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/dummies/#{dummy}")

      html = render(show_live)
      assert html =~ "Dummy updated successfully"
      assert html =~ "some updated name"
    end
  end
end
