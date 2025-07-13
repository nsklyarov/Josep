# scripts/windows/install_dependencies.ps1

$Deps = @(
    @{ name = "CryptoLib4Pascal"; url = "https://github.com/Xor-el/CryptoLib4Pascal.git"; commit = "f187ab08ea73cf3158102c2a8e133b38dbfc34a1" },
    @{ name = "HashLib4Pascal"; url = "https://github.com/Xor-el/HashLib4Pascal.git"; commit = "d18a58cdf3163c9da439143c449748779532581a" },
    @{ name = "SimpleBaseLib4Pascal"; url = "https://github.com/Xor-el/SimpleBaseLib4Pascal.git"; commit = "c87f112b089cdb57d26a5793cc8335cd36d317d8" }
)

$LibDir = "lib"
New-Item -ItemType Directory -Force -Path $LibDir | Out-Null

foreach ($dep in $Deps) {
    $path = "$LibDir\$($dep.name)"
    if (Test-Path $path) {
        Write-Host "🔁 Updating $($dep.name)..."
        Push-Location $path
        git fetch origin
        git checkout $($dep.commit)
        Pop-Location
    } else {
        Write-Host "⬇️ Cloning $($dep.name)..."
        git clone $($dep.url) $path
        Push-Location $path
        git checkout $($dep.commit)
        Pop-Location
    }
}

Write-Host "✅ Dependencies are ready in '$LibDir'"
