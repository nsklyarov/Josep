@echo off
setlocal ENABLEDELAYEDEXPANSION

echo [🚀] Running examples in Josep.Samples...

set SAMPLE_DIR=Josep.Samples\src
set BUILD_DIR=build\bin

for %%f in (%SAMPLE_DIR%\*.pas) do (
    set "EXE_NAME=%%~nf"
    set "BIN=%BUILD_DIR%\%%~nf.exe"

    if exist !BIN! (
        echo.
        echo [▶] Running %%~nf... (press Enter to continue)
        pause > nul
        call "!BIN!"
        if !errorlevel! equ 0 (
            echo [✅] %%~nf finished successfully
        ) else (
            echo [❌] %%~nf failed with exit code !errorlevel!
        )
    ) else (
        echo [⚠️] Binary %%~nf.exe not found. Did you forget to build?
    )
)

endlocal
