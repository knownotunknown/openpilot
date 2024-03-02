if [ "$1" = "base" ]; then
  if [ -f "$(dirname "$0")/openpilot_base.sh" ]; then
    echo "Did we make it here?"
    sudo source "$(dirname "$0")/openpilot_base.sh"
  else
    echo "openpilot_base.sh not found in the script directory."
    exit 1
  fi
elif [ "$1" = "sim" ]; then
  export DOCKER_IMAGE=openpilot-sim
  export DOCKER_FILE=tools/sim/Dockerfile.sim
elif [ "$1" = "prebuilt" ]; then
  export DOCKER_IMAGE=openpilot-prebuilt
  export DOCKER_FILE=Dockerfile.openpilot
else
  echo "Invalid docker build image: '$1'"
  exit 1
fi

export DOCKER_REGISTRY=ghcr.io/commaai
export COMMIT_SHA=$(git rev-parse HEAD)

TAG_SUFFIX=$2
LOCAL_TAG=$DOCKER_IMAGE$TAG_SUFFIX
REMOTE_TAG=$DOCKER_REGISTRY/$LOCAL_TAG
REMOTE_SHA_TAG=$DOCKER_REGISTRY/$LOCAL_TAG:$COMMIT_SHA
