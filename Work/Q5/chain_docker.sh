#!/usr/bin/env bash

# 1) Build the Q2 container (assuming a Dockerfile.q2 already exists)
docker build -t q2_runner -f Dockerfile.q2 .

# 2) Generate images from the Q2 code
mkdir -p output
docker run --rm -v $(pwd)/output:/app/output q2_runner \
  --plant "Tulip" --height 30 35 40 --leaf_count 12 14 16 --dry_weight 1.0 1.2 1.5

# 3) Build the Java marker container
docker build -t java_marker -f Dockerfile.java .

# 4) Run the Java container to watermark with your name and ID
docker run --rm -v $(pwd)/output:/images java_marker /images "Hossen Hossen ID=322389511"

# 5) Clean up images
docker rmi q2_runner java_marker -f
