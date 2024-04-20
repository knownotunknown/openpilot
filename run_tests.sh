#!/bin/bash

# Exit script on error
set -e

# Source the XVFB setup script
source selfdrive/test/setup_xvfb.sh

# Determine Python path based on input argument
if [ "$1" == "single" ]; then
    PYTHON_EXEC_PATH=“/usr/bin/python3”
else
    PYTHON_EXEC_PATH="/usr/local/bin/python3.11"
fi

# Run the Docker container with necessary environment variables and volume mounts
docker run --shm-size 1G -w /tmp/openpilot -e CI=1 -e PRE_COMMIT_HOME=/tmp/pre-commit -e PYTHONWARNINGS="ignore::DeprecationWarning" -e FILEREADER_CACHE=1 -e PYTHONPATH=/tmp/openpilot -e NUM_JOBS -e JOB_ID -e GITHUB_ACTION -e GITHUB_REF -e GITHUB_HEAD_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_RUN_ID -v $GITHUB_WORKSPACE/.ci_cache/pre-commit:/tmp/pre-commit -v $GITHUB_WORKSPACE/.ci_cache/scons_cache:/tmp/scons_cache -v $GITHUB_WORKSPACE/.ci_cache/comma_download_cache:/tmp/comma_download_cache -v $GITHUB_WORKSPACE/.ci_cache/openpilot_cache:/tmp/openpilot_cache -v $PWD/common:/tmp/openpilot/common -v $PWD/selfdrive/athena:/tmp/openpilot/selfdrive/athena -v $PWD/selfdrive/boardd:/tmp/openpilot/selfdrive/boardd -v $PWD/selfdrive/car:/tmp/openpilot/selfdrive/car -v $PWD/selfdrive/controls:/tmp/openpilot/selfdrive/controls -v $PWD/selfdrive/locationd:/tmp/openpilot/selfdrive/locationd -v $PWD/selfdrive/monitoring:/tmp/openpilot/selfdrive/monitoring -v $PWD/selfdrive/navd/tests:/tmp/openpilot/selfdrive/navd/tests -v $PWD/selfdrive/thermald:/tmp/openpilot/selfdrive/thermald -v $PWD/selfdrive/test/longitudinal_maneuvers:/tmp/openpilot/selfdrive/test/longitudinal_maneuvers -v $PWD/selfdrive/test/process_replay/test_fuzzy.py:/tmp/openpilot/selfdrive/test/process_replay/test_fuzzy.py -v $PWD/system/camerad:/tmp/openpilot/system/camerad -v $PWD/system/hardware/tici:/tmp/openpilot/system/hardware/tici -v $PWD/system/loggerd:/tmp/openpilot/system/loggerd -v $PWD/system/proclogd:/tmp/openpilot/system/proclogd -v $PWD/system/tests:/tmp/openpilot/system/tests -v $PWD/system/ubloxd:/tmp/openpilot/system/ubloxd -v $PWD/system/webrtc:/tmp/openpilot/system/webrtc -v $PWD/tools/lib/tests:/tmp/openpilot/tools/lib/tests -v $PWD/tools/replay:/tmp/openpilot/tools/replay -v $PWD/tools/cabana:/tmp/openpilot/tools/cabana --env DISPLAY=:99 --volume /tmp/.X11-unix:/tmp/.X11-unix ghcr.io/knownotunknown/openpilot:latest /bin/bash -c "\
    export MAPBOX_TOKEN='pk.eyJ1Ijoiam5ld2IiLCJhIjoiY2xxNW8zZXprMGw1ZzJwbzZneHd2NHljbSJ9.gV7VPRfbXFetD-1OVF0XZg' && \
    $PYTHON_EXEC_PATH -m pytest --continue-on-collection-errors --cov --cov-report=xml --cov-append --durations=0 --durations-min=5 --hypothesis-seed 0 -n logical --timeout 60 -m 'not slow' && \
    ./selfdrive/ui/tests/create_test_translations.sh && \
    QT_QPA_PLATFORM=offscreen ./selfdrive/ui/tests/test_translations && \
    ./selfdrive/ui/tests/test_translations.py"
