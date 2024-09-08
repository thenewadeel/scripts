#!/bin/bash

convert "$1" -crop 720x1280 +repage "output_%03d.jpg"
