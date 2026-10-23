# Python tooling

Internal development scripts, managed with Poetry.

[fill_strings_from_arb.py](bin/fill_strings_from_arb.py) copies plain-text ARB
messages to missing native `.strings` keys using [JSON mappings](../../configs/l10n_strings_refs.json).
Existing values remain unchanged; missing source messages are skipped.
`--check` verifies without writing.

From the app root:

```sh
make sync-native-l10n
bash scripts/sync_native_l10n.sh --check
```

Run local tests from this directory:

```sh
poetry install --with test --no-root
poetry run pytest
```
