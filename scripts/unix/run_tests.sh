#!/bin/bash

set -e

echo "🧪 Running Josep tests..."

TEST_BIN="build/bin/JosepTests"

echo "▶ Executing tests..."
"$TEST_BIN"
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  echo "✅ All tests passed"
else
  echo "❌ Some tests failed (exit code $exit_code)"
fi

exit $exit_code
