<!--
Title: Pre-Released or Released: v1.2.3+xx
-->

# Pre-Released

## v1.15.5+63

- Fix several issues from db operations:
  - typo in var name of custom sql.
  - use correct type of field: Record.reason.
  - use "update" instead of "replace" when trying to insert multi records.
  - use transaction when inserting multi records.
- Fix issue where status can't be modified for today on multi-habits-changer page.
- Update Traditional Chinese l10n translation, thank for Peter Dave Hello's contribution on Github.
