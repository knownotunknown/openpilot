#!/bin/bash

scons -j$(nproc)

# Export MAPBOX_TOKEN
export MAPBOX_TOKEN='pk.eyJ1Ijoiam5ld2IiLCJhIjoiY2xxNW8zZXprMGw1ZzJwbzZneHd2NHljbSJ9.gV7VPRfbXFetD-1OVF0XZg'

# Run pytest
pytest --continue-on-collection-errors --cov --cov-report=xml --cov-append --durations=0 --durations-min=5 --hypothesis-seed 0 -n logical --timeout 60 -m 'not slow'

# Create test translations
./selfdrive/ui/tests/create_test_translations.sh

# Run translation tests
QT_QPA_PLATFORM=offscreen ./selfdrive/ui/tests/test_translations
./selfdrive/ui/tests/test_translations.py
