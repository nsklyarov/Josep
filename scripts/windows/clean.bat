@echo off
echo [🧹] Cleaning build artifacts...
rd /s /q build 2>nul
for /r %%f in (*.o *.ppu *.a *.rst *.or) do del "%%f"
echo [✅] Clean complete.
