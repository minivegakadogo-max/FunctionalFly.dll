# FlyPremium — Bedrock 26.60 client mod

Native LeviLamina client mod. Press `X` in a loaded world to toggle the player's native `MayFly` and `Flying` abilities. Press `X` again to restore the values captured when the player was first detected. It uses LeviLamina client APIs rather than hard-coded game offsets.

## Compatibility

- Target: Minecraft Bedrock 26.60, Windows x64 client.
- LeviLamina source: `feat/26.60` pinned to `6c5ea1f45a93e4c8b5d887d7419707b4fe8ecd04`.
- Loader: LeviLamina client through LeviLauncher.
- This is a LeviLamina mod module, not a standalone Fate Injector DLL.

## Build prerequisites

- Windows 10/11 x64.
- Visual Studio 2022 or Build Tools with Desktop development with C++, MSVC x64 tools and Windows SDK.
- LLVM 22 with `clang-cl` on PATH.
- XMake 3.0.0 or newer.
- Git on PATH.
- Internet access for source and dependency downloads.

## Build

A GitHub Actions workflow runs on pushes to `main` and manual dispatch using a Windows runner. It configures the `client` x64 release target, builds `FlyPremium.dll`, packages it with `manifest.json`, and uploads the result as an Actions artifact. A build log is also uploaded when the build fails.

To build locally, run `build.bat` from a Windows Command Prompt with the prerequisites installed.

## Usage

1. Install a LeviLamina-enabled Bedrock client through LeviLauncher.
2. Put the built mod folder in the client `mods` directory (LeviLauncher can manage/import client mods).
3. Launch the matching Bedrock 26.60 client with LeviLamina.
4. Enter a world and press `X` to enable flight; press `X` again to restore the original ability values.

The mod toggles the player's client-side ability state. A remote server can deny or overwrite player abilities.

## API / offset disclaimer

The mod calls `IClientInstance::getLocalPlayer()` and `Player::setAbility()` through LeviLamina's C++ API. It does not contain guessed addresses or hard-coded game offsets.
