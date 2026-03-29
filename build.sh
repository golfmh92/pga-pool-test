#!/bin/bash
set -e

mkdir -p dist

cp index.html dist/index.html
cp sw.js dist/sw.js

echo "Build complete: dist/index.html + sw.js"
