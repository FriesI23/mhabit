# Python tooling

Internal development scripts, managed with Poetry.

[select_ios_simulator.py](bin/select_ios_simulator.py) resolves the default
iPhone simulator destination for native XCTest on macOS. The iOS Make targets
run it through this Poetry environment; `IOS_TEST_DESTINATION` overrides it.

[fill_strings_from_arb.py](bin/fill_strings_from_arb.py) copies plain-text ARB
messages to missing native `.strings` keys using [JSON mappings](../../configs/l10n_strings_refs.json).
Existing values remain unchanged; missing source messages are skipped.
`--check` verifies without writing.

From the app root:

```sh
make sync-native-l10n
bash scripts/sync_native_l10n.sh --check
```

Install the optional test dependencies from this directory:

```sh
poetry install --with test --no-root
```

Then run `make test-scripts` from the app or workspace root.
`make test-all` and `make aio-full` include these tests; CI keeps its existing
test entrypoints and does not run them.
