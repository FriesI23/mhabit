# mhabit Project Style

This file captures project-level coding choices that go beyond generic Dart or
Flutter style. Use it when introducing, renaming, or placing new boundary
contracts during refactor work.

## Boundary Naming

- Name a contract by the concrete responsibility it exposes.
- Reserve `Owner` for seams that really own a workflow or lifecycle, such as
  coordinating reads, writes, follow-up effects, invalidation, or orchestration.
- For narrower read-only or role-limited seams, prefer more explicit names such
  as `Queries`, `Reader`, `QueryAccess`, `Commands`, `Settings`, `StatusSource`,
  or `Trigger`, depending on the semantics.
- For a consumer-local mixed subset that combines read and write capabilities
  but still does not own orchestration, prefer `Access` over generic names like
  `Boundary` or misleading names like `Manager`.
- A read-only display seam should usually prefer a name like
  `HabitsDisplayQueries` over `HabitsDisplayQueryOwner`.
- Do not churn existing code only to satisfy this naming rule. Apply it when
  the current slice is already changing that seam.

## Interface Placement

- Do not default to one Dart file per interface.
- Small related interfaces in the same boundary family should usually live in a
  shared file, such as a seam-local `*_contracts.dart` or another boundary file
  that groups adjacent query, command, status, or trigger contracts.
- Split an interface into its own file only when it is independently reused
  across distant domains, the grouped file becomes noisy, or visibility / code
  generation constraints make the split clearer.
- Before creating a new interface file, first check whether the contract belongs
  in an existing boundary family file.

## Slice Self-Check

- Before introducing a contract, ask whether the seam is query, command,
  status, trigger, or a real owner.
- Before creating a file, ask whether the contract starts a new family or
  belongs in an existing boundary file.
- Prefer the smallest active slice. Do not rename, move, or aggregate adjacent
  seams unless that is part of the current slice.

## Current Preference

- The current project preference is that `queryOwner` is serviceable but too
  generic for a read-only seam. Future code should prefer a more role-explicit
  query name when that slice is already being touched.
- The same preference applies to mixed consumer-local subset seams: prefer
  names like `HabitDetailAccess`, `HabitsDisplayAccess`, or
  `HabitStatusChangerAccess` over `*Boundary` or `*Manager`.
- The same preference applies to earlier narrow interfaces from the AppSync
  slices: prefer grouping related small seam contracts instead of growing a
  one-file-per-interface pattern.
