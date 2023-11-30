defmodule Planet.DummiesTest do
  use Planet.DataCase

  alias Planet.Dummies

  describe "dummies" do
    alias Planet.Dummies.Dummy

    import Planet.DummiesFixtures

    @invalid_attrs %{name: nil, age: nil}

    test "list_dummies/0 returns all dummies" do
      dummy = dummy_fixture()
      assert Dummies.list_dummies() == [dummy]
    end

    test "get_dummy!/1 returns the dummy with given id" do
      dummy = dummy_fixture()
      assert Dummies.get_dummy!(dummy.id) == dummy
    end

    test "create_dummy/1 with valid data creates a dummy" do
      valid_attrs = %{name: "some name", age: 42}

      assert {:ok, %Dummy{} = dummy} = Dummies.create_dummy(valid_attrs)
      assert dummy.name == "some name"
      assert dummy.age == 42
    end

    test "create_dummy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dummies.create_dummy(@invalid_attrs)
    end

    test "update_dummy/2 with valid data updates the dummy" do
      dummy = dummy_fixture()
      update_attrs = %{name: "some updated name", age: 43}

      assert {:ok, %Dummy{} = dummy} = Dummies.update_dummy(dummy, update_attrs)
      assert dummy.name == "some updated name"
      assert dummy.age == 43
    end

    test "update_dummy/2 with invalid data returns error changeset" do
      dummy = dummy_fixture()
      assert {:error, %Ecto.Changeset{}} = Dummies.update_dummy(dummy, @invalid_attrs)
      assert dummy == Dummies.get_dummy!(dummy.id)
    end

    test "delete_dummy/1 deletes the dummy" do
      dummy = dummy_fixture()
      assert {:ok, %Dummy{}} = Dummies.delete_dummy(dummy)
      assert_raise Ecto.NoResultsError, fn -> Dummies.get_dummy!(dummy.id) end
    end

    test "change_dummy/1 returns a dummy changeset" do
      dummy = dummy_fixture()
      assert %Ecto.Changeset{} = Dummies.change_dummy(dummy)
    end
  end
end
