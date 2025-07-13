#!/bin/bash

set -e

echo "📦 Resolving dependencies..."
./scripts/unix/install_dependencies.sh

echo "🛠️  Building examples..."

FPC_FLAGS="-Mdelphi"
BUILD_DIR="build/bin"
mkdir -p "$BUILD_DIR"

FPC_UNITS=$(cat <<EOF
-Fu./src
-Fu./lib/CryptoLib4Pascal/CryptoLib/src
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Interfaces
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Utils
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Utils/Encoders
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Utils/Rng
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Utils/Randoms
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Crypto
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Crypto/Macs
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Crypto/Digests
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Crypto/Prng
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Crypto/Engines
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Crypto/Parameters
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Math
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Security
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/Pkcs
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/RossStandart
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/Oiw
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/Nist
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/Misc
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/TeleTrust
-Fu./lib/CryptoLib4Pascal/CryptoLib/src/Asn1/CryptoPro
-Fu./lib/HashLib4Pascal/HashLib/src
-Fu./lib/HashLib4Pascal/HashLib/src/Base
-Fu./lib/HashLib4Pascal/HashLib/src/Interfaces
-Fu./lib/HashLib4Pascal/HashLib/src/Interfaces/IBlake2BParams
-Fu./lib/HashLib4Pascal/HashLib/src/Interfaces/IBlake2SParams
-Fu./lib/HashLib4Pascal/HashLib/src/Crypto/Blake2BParams
-Fu./lib/HashLib4Pascal/HashLib/src/Crypto/Blake2SParams
-Fu./lib/HashLib4Pascal/HashLib/src/Params
-Fu./lib/HashLib4Pascal/HashLib/src/Utils
-Fu./lib/HashLib4Pascal/HashLib/src/KDF
-Fu./lib/HashLib4Pascal/HashLib/src/Nullable
-Fu./lib/HashLib4Pascal/HashLib/src/NullDigest
-Fu./lib/HashLib4Pascal/HashLib/src/Checksum
-Fu./lib/HashLib4Pascal/HashLib/src/Hash32
-Fu./lib/HashLib4Pascal/HashLib/src/Hash64
-Fu./lib/HashLib4Pascal/HashLib/src/Hash128
-Fu./lib/HashLib4Pascal/HashLib/src/Crypto
-Fu./lib/SimpleBaseLib4Pascal/SimpleBaseLib/src
-Fu./lib/SimpleBaseLib4Pascal/SimpleBaseLib/src/Bases
-Fu./lib/SimpleBaseLib4Pascal/SimpleBaseLib/src/Utils
-Fu./lib/SimpleBaseLib4Pascal/SimpleBaseLib/src/Interfaces
EOF
)

for file in Josep.Samples/src/*.pas; do
  exe_name=$(basename "$file" .pas)
  echo "🚀 Compiling $file..."
  fpc $FPC_FLAGS $FPC_UNITS "$file" -o"${BUILD_DIR}/${exe_name}"
done

echo "🧪 Compiling tests..."
fpc $FPC_FLAGS $FPC_UNITS Josep.Tests/src/JosepTests.pas -o"build/bin/JosepTests"

echo "✅ Build complete."
