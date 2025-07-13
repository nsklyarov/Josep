@echo off
setlocal

echo [📦] Resolving dependencies...
call scripts\windows\install_dependencies.bat

echo [🛠️] Building examples...

set FPC_FLAGS=-Mdelphi
set BUILD_DIR=build\bin

if not exist %BUILD_DIR% mkdir %BUILD_DIR%

for %%f in (Josep.Samples\src\*.pas) do (
    set "EXE_NAME=%%~nf"
    echo [🚀] Compiling %%f
    fpc %FPC_FLAGS% %%f -o%BUILD_DIR%\%%~nf.exe
)

fpc %FPC_FLAGS% Josep.Tests\src\JosepTests.pas -o%BUILD_DIR%\JosepTests.exe

echo [✅] Build complete.
endlocal
