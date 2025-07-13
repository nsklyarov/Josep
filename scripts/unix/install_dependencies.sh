#!/bin/bash

set -e

LIB_DIR="lib"
mkdir -p "$LIB_DIR"

deps=(
  "CryptoLib4Pascal https://github.com/Xor-el/CryptoLib4Pascal.git f187ab08ea73cf3158102c2a8e133b38dbfc34a1"
  "HashLib4Pascal https://github.com/Xor-el/HashLib4Pascal.git d18a58cdf3163c9da439143c449748779532581a"
  "SimpleBaseLib4Pascal https://github.com/Xor-el/SimpleBaseLib4Pascal.git c87f112b089cdb57d26a5793cc8335cd36d317d8"
)

clone_or_update() {
  local name="$1"
  local url="$2"
  local commit="$3"
  local path="$LIB_DIR/$name"

  if [ -d "$path" ]; then
    echo "🔁 Updating $name..."
    cd "$path"
    git fetch origin
    git checkout "$commit"
    cd - > /dev/null
  else
    echo "⬇️ Cloning $name..."
    git clone "$url" "$path"
    cd "$path"
    git checkout "$commit"
    cd - > /dev/null
  fi
}

for dep in "${deps[@]}"; do
  clone_or_update $dep
done

echo "✅ Dependencies are ready in '$LIB_DIR/'"
