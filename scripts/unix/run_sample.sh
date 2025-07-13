#!/bin/bash

set -e

echo "🚀 Running examples in Josep.Samples..."

for example in Josep.Samples/src/*.pas; do
  exe_name=$(basename "$example" .pas)
  bin="build/bin/$exe_name"

  if [[ -f "$bin" ]]; then
    echo
    echo "▶ Running $exe_name... (press Enter to continue)"
    read -r
    "$bin"
    exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
      echo "✅ $exe_name finished successfully"
    else
      echo "❌ $exe_name failed with exit code $exit_code"
    fi
  else
    echo "⚠️  Binary $exe_name not found. Did you forget to build?"
  fi
done
