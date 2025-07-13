@echo off
setlocal

set TEST_BIN=build\bin\JosepTests.exe

echo [🧪] Running Josep tests...

if exist %TEST_BIN% (
    call "%TEST_BIN%"
    set EXIT_CODE=%ERRORLEVEL%

    if %EXIT_CODE% equ 0 (
        echo [✅] All tests passed
    ) else (
        echo [❌] Some tests failed (exit code %EXIT_CODE%)
    )

    exit /b %EXIT_CODE%
) else (
    echo [⚠️] Test binary not found. Did you forget to build?
    exit /b 1
)

endlocal
