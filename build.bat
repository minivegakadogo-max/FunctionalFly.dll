@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ============================================================
echo FlyPremium - Minecraft Bedrock 26.60 client mod
echo Pinned LeviLamina source: 6c5ea1f45a93e4c8b5d887d7419707b4fe8ecd04
echo ============================================================

where xmake >nul 2>nul
if errorlevel 1 (
    echo [ERROR] xmake is missing. Install XMake 3.0.0 or newer.
    goto :failed
)
where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git is missing or not in PATH.
    goto :failed
)

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [ERROR] Visual Studio 2022 / Build Tools with C++ workload was not found.
    goto :failed
)

set "VSROOT="
for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSROOT=%%I"
if not defined VSROOT (
    echo [ERROR] MSVC x64 build tools were not found in Visual Studio.
    goto :failed
)

if not exist "%VSROOT%\Common7\Tools\VsDevCmd.bat" (
    echo [ERROR] VsDevCmd.bat is missing from the Visual Studio installation.
    goto :failed
)
call "%VSROOT%\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64 -no_logo
if errorlevel 1 goto :failed

where clang-cl >nul 2>nul
if errorlevel 1 (
    echo [ERROR] clang-cl is missing. Install LLVM 22 and add its bin folder to PATH.
    goto :failed
)
where cl >nul 2>nul
if errorlevel 1 (
    echo [ERROR] MSVC compiler environment was not initialized.
    goto :failed
)

if not exist build mkdir build

echo.
echo [1/2] Configuring Windows x64 client build...
xmake f -c -y -p windows -a x64 -m release --target_type=client
if errorlevel 1 goto :failed

echo.
echo [2/2] Building FlyPremium and its pinned LeviLamina dependency...
xmake -v -y > "build\build.log" 2>&1
if errorlevel 1 (
    echo [ERROR] Build failed. Last 100 lines:
    powershell -NoProfile -Command "Get-Content 'build/build.log' -Tail 100"
    goto :failed
)

set "BUILT_DLL="
for /r "bin" %%F in (FlyPremium.dll) do set "BUILT_DLL=%%F"
if not defined BUILT_DLL (
    for /r "build" %%F in (FlyPremium.dll) do set "BUILT_DLL=%%F"
)
if not defined BUILT_DLL (
    echo [ERROR] Build returned success but FlyPremium.dll was not found.
    goto :failed
)

echo.
echo [SUCCESS] DLL created:
echo %BUILT_DLL%
echo Keep manifest.json beside the DLL in the mod folder.
exit /b 0

:failed
echo.
echo [FAILED] No working DLL was produced.
echo Review build\build.log. The pinned LeviLamina 26.60 dependency passed its upstream Windows CI.
exit /b 1
