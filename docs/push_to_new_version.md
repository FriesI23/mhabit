# Bump version

1. Modify `pubspec.yaml` and change `version` param
2. Add new release change log in `CHANGELOG.md`
   1. (Optional) Add translation text at `docs/CHANGELOG/<locale>.md`
3. (For android) Copy current version code change log from `CHANGELOG.md` to `{versionCode}.txt` (create a new file if not exist) at `fastlane/metadata/android/en-us/changelogs`.
   1. (Optional) Add translation text at `fastlane/metadata/android/<locale>/changelogs`
   2. (Optional) Or run `./scripts/gen_changelogs.sh` to auto generate changelogs from `CHANGELOG.md`
