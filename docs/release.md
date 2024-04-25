# Pre-Released

## 1.12.1+38

- Add support for the Windows platform. (#164)
- Add Russian translation. (#169)
- Add Add support for `dmg` build on macos. (#168)
- Add `pre-release` version build process. (#171)
- Fixed issue in `OpenContainer` raise exception when navigating via `Tooltips` enabled. (#166)
- Update iOS dependency package versions.
- Optimize code quality.

### Build Windows version of `Table Habit`

```sh
flutter config --enable-windows-desktop
flutter build windows --release
```

### Build `dmg` package on `MacOS`

1. Install `node` if not exist. if using `brew`, a simple way to install with `brew install node` commaned.
2. Install `appdmg` with executing `npm install -g appdmg`
3. Run `./scripts/build_dmg.sh` and wait this job done.
4. Target is located at `./build/macos_dmg/mhabit-yyyy-mm-dd-HH-MM-SS.dmg`.
