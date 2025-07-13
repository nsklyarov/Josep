#!/bin/bash

echo "🧹 Cleaning build artifacts..."
rm -rf build/
find . -type f \( -name "*.o" -o -name "*.ppu" -o -name "*.a" -o -name "*.rst" -o -name "*.or" \) -delete
echo "✅ Clean complete."
