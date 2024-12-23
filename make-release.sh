set -xo errexit

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install Docker to use this script."
    exit 1
fi

# Check if the script is running on macOS & Start Docker Desktop if not running
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo "Docker is not running. Starting Docker Desktop..."
        open --background -a Docker
        # Wait until Docker is running
        while ! docker info > /dev/null 2>&1; do
            echo "Waiting for Docker to start..."
            sleep 2
        done
        echo "Docker is now running."
    fi
fi

BUILDPLATFORM=linux/amd64
#Everything is cached so no problem running build again
docker build --platform=$BUILDPLATFORM -t planet-amd64-platform -f ./Dockerfile ./
docker run --rm -it --platform=$BUILDPLATFORM --volume ./:/app planet-amd64-platform

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Getting Deps For Host Enviornment As Two Way Sync Removes Them"
    # Reinstall Deps For Host Enviornment
    # Make Deps For Host Enviornment Back Again As Sync Might Have Deleted Something
    mix deps.get
    mix compile
fi

# docker run --entrypoint="/bin/bash" --rm -it --platform=linux/amd64 --volume .:/app -t planet-amd64-platform:latest

