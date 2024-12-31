<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Released: v1.14.4+57

- Strip `DependenciesInfo` block from android, resolve [#205](https://github.com/FriesI23/mhabit/issues/205).

Change logs below are from v1.14.3+56:

- Add Windows MSIX Installer.
- Add separate error page when app crashes during startup.
- Fix issues with incorrect usage of `Completer`.
- Change debug log path to `Cache` directory.
- Change database path to `Support` directory on non-android platforms.
- Update Ukrainian translation, thank for Максим Горпиніч's contribution on Weblate.

**WARNING**: Because changing database path will involve file migration,
it's strongly recommended to backup (export) habits before upgrading.
