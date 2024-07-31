set -xo errexit

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install Docker to use this script."
    exit 1
fi


#Everything is cached so no problem running build again
docker build --platform='linux/amd64' -t phx-image-amd64-platform -f ./Dockerfile ./
docker run --rm -it --platform='linux/amd64' --volume ./:/app phx-image-amd64-platform
# docker run --entrypoint="/bin/bash" --rm -it --platform=linux/amd64 --volume .:/app -t phx-image

# Make Deps For Host Enviornment Back Again As Sync Might Have Deleted Somethings
# mix deps.get
# mix compile
#Override Entrypoint