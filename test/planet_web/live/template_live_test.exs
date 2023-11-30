defmodule PlanetWeb.TemplateLiveTest do
  use PlanetWeb.ConnCase

  import Phoenix.LiveViewTest
  import Planet.TemplatesFixtures

  @create_attrs %{age: 42, name: "some name"}
  @update_attrs %{age: 43, name: "some updated name"}
  @invalid_attrs %{age: nil, name: nil}

  defp create_template(_) do
    template = template_fixture()
    %{template: template}
  end

  describe "Index" do
    setup [:create_template]

    test "lists all templates", %{conn: conn, template: template} do
      {:ok, _index_live, html} = live(conn, ~p"/templates")

      assert html =~ "Listing Templates"
      assert html =~ template.name
    end

    test "saves new template", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/templates")

      assert index_live |> element("a", "New Template") |> render_click() =~
               "New Template"

      assert_patch(index_live, ~p"/templates/new")

      assert index_live
             |> form("#template-form", template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#template-form", template: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/templates")

      html = render(index_live)
      assert html =~ "Template created successfully"
      assert html =~ "some name"
    end

    test "updates template in listing", %{conn: conn, template: template} do
      {:ok, index_live, _html} = live(conn, ~p"/templates")

      assert index_live |> element("#templates-#{template.id} a", "Edit") |> render_click() =~
               "Edit Template"

      assert_patch(index_live, ~p"/templates/#{template}/edit")

      assert index_live
             |> form("#template-form", template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#template-form", template: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/templates")

      html = render(index_live)
      assert html =~ "Template updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes template in listing", %{conn: conn, template: template} do
      {:ok, index_live, _html} = live(conn, ~p"/templates")

      assert index_live |> element("#templates-#{template.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#templates-#{template.id}")
    end
  end

  describe "Show" do
    setup [:create_template]

    test "displays template", %{conn: conn, template: template} do
      {:ok, _show_live, html} = live(conn, ~p"/templates/#{template}")

      assert html =~ "Show Template"
      assert html =~ template.name
    end

    test "updates template within modal", %{conn: conn, template: template} do
      {:ok, show_live, _html} = live(conn, ~p"/templates/#{template}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Template"

      assert_patch(show_live, ~p"/templates/#{template}/show/edit")

      assert show_live
             |> form("#template-form", template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#template-form", template: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/templates/#{template}")

      html = render(show_live)
      assert html =~ "Template updated successfully"
      assert html =~ "some updated name"
    end
  end
end
