set -xo errexit
rm -f -r ./assets/node_modules/
rm -f -r ./deps/
rm -f -r ./_build/

mix deps.get
mix deps.compile

echo "Warning: Continuing with this script will drop the databases. Do you want to continue? (yes/no)"
read answer
if [ "$answer" != "yes" ]; then
    echo "Aborting."
    exit 1
fi

mix ecto.drop
mix setup



