# AI rules for mhabit

You are working in the `mhabit` repository, a Flutter app with a local Flutter
SDK, Melos-managed internal packages, provider-based state wiring, profile-backed
app settings, generated code, and multi-platform release workflows.

Your goal is to make the smallest correct change that preserves the repo's
existing architecture and tooling contracts.

## Interaction Guidelines

- Confirm the target path before editing and keep changes scoped to the active
  slice.
- Prefer repo-root-relative paths when describing files, commands, or plans.
- Prefer the smallest coherent edit over broad cleanup.
- Treat existing repo patterns as the first choice. Do not introduce a new
  architectural style when an established local pattern already exists.
- Reuse existing dependencies and abstractions before proposing a new package,
  new state-management layer, or new helper surface.
- When the request touches generated, localized, or build-managed files,
  explain which source file or generation command actually owns the result.

## Rule Maintenance And Self-Reflection

- Treat this file as a living repo contract, not as a frozen template.
- When a task reveals that the repo's stable structure, workflow, naming, or
  architecture has changed, check whether this file is now stale.
- Update this file when the new behavior is already reflected in code,
  build/config files, or nearby repo docs and is intended to be the new normal.
- Do not update this file for temporary experiments, incomplete migrations, or
  one-off local inconsistencies.
- If your code change intentionally changes the repo's stable conventions, treat
  the matching `docs/rules/rules.md` update as part of the same task unless the
  user explicitly wants code-only work.
- Keep rule updates minimal and evidence-based. Prefer adjusting the affected
  section instead of rewriting the whole document.
- When updating rules, anchor them to current repo-owned sources such as
  `Makefile`, `analysis_options.yaml`, `pubspec.yaml`, entry wiring, provider
  assembly, or stable docs under `docs/`.
- After changing this file, validate Markdown diagnostics and make sure any
  referenced commands, paths, or boundaries still match the repo.

## Repository Workflow

- This repo uses the vendored Flutter SDK under `.flutter/`.
- Prefer the repo `Makefile` entrypoints instead of ad-hoc commands when an
  equivalent target already exists.
- Standard commands:
  - `make init` or `make bootstrap`: initialize submodules, hooks, and Melos.
  - `make format`: format Dart code in the app and internal packages.
  - `make fix`: apply Dart fixes, then format.
  - `make gen`: run normalization, icon generation, and build generation.
  - `make verify-generated`: verify generated and normalized outputs are current.
  - `make test`: run the root app and internal package tests.
  - `make aio`: run `gen`, `fix`, and `verify-generated`.
  - `make aio-full`: run `aio` plus tests.
- `normalize-l10n` and `verify-generated` are intentionally Make-owned wrapper
  commands. Do not replace them with a new custom workflow.
- When a task touches generated artifacts, prefer validating with `make gen` or
  `make verify-generated` instead of editing generated outputs directly.

## Project Structure

- `lib/main.dart` owns startup ordering. Keep binding, logging, app info,
  notification, and timezone initialization there before `runApp`.
- `lib/entries/app/entry.dart` owns high-level app assembly. It wires profile
  loading, database loading, provider injection, dynamic color, and the app
  shell.
- `lib/entries/common/app_root_view.dart` owns the `MaterialApp` shell.
  Keep global app-level concerns such as locale, theme, navigator keys,
  localization delegates, and top-level builders there.
- Shared app-scoped provider code lives under:
  - `lib/providers/app_ui/` for app-wide UI preferences and view models.
  - `lib/providers/workflow/` for business workflow owners and access seams.
  - `lib/providers/support/` for support objects that are shared but not page
    features.
- Page-local provider/view model code belongs close to its page under
  `lib/pages/**/_providers/` when the behavior is local to that page family.
- Models and domain-like data structures live in `lib/models/`.
- Persistence and profile-backed storage logic live in `lib/storage/`.
- Theme and generated icon/color code live in `lib/theme/`.
- Localization outputs live in `lib/l10n/`.

## Architecture Rules

- Preserve the existing owner boundary instead of flattening layers.
- Keep widgets focused on rendering and UI composition. Move persistence,
  workflow coordination, and app-level mutable state into providers, owners, or
  storage helpers.
- Prefer explicit composition over inheritance for app assembly and feature
  behavior.
- Keep startup concerns at the entry layer, not inside random pages or widgets.
- Reuse existing caller-facing seams before adding a new one. In this repo,
  that usually means reusing existing `*Access`, `*Owner`, or `*ViewModel`
  contracts.
- Prefer local ownership over generic helper extraction. If logic only serves a
  single owner or page family, keep it same-file private or page-local.
- Do not widen a page-local concern into `lib/providers/` unless it is clearly
  reused across page families.

## Provider And State Management

- The repo uses `provider` as the primary dependency-injection and state wiring
  mechanism.
- `ChangeNotifier`, `ProxyProvider`, `ListenableProxyProvider`, and repo-local
  proxy helpers are the normal patterns. Stay consistent with them.
- Use `AppProviders` in `lib/entries/app/providers.dart` as the root provider
  assembly point for app-scoped wiring.
- Keep provider ownership explicit:
  - if a proxy owns the notifier, prefer a single proxy-based creation path with
    explicit `create`;
  - avoid duplicating ownership with a same-type provider plus same-type proxy
    unless there is a real lifecycle reason.
- When an access interface is backed by a `Listenable` implementation, expose it
  through `ListenableProxyProvider` or `ListenableProvider`, not plain
  `ProxyProvider`.
- Prefer `context.select(...)` or other narrow reads over broad rebuild wiring
  when a widget only needs a small piece of state.
- App-scoped UI preferences are typically profile-backed view models under
  `lib/providers/app_ui/`.
- Workflow-side mutable behavior belongs under `lib/providers/workflow/`.

## Profile-Backed Settings

- Persistent app settings are profile-backed. Prefer extending the existing
  profile-handler system over direct, scattered `SharedPreferences` calls.
- `ProfileViewModel` owns handler initialization and typed handler lookup.
- New persisted settings should usually be introduced as a dedicated profile
  handler in `lib/storage/profile/handlers/` plus the matching view model or
  owner integration.
- Keep preference serialization near the handler using a `Codec` or `Converter`
  when the value is not trivially scalar.
- Avoid leaking raw storage shapes into UI code.

## Models, Serialization, And Dynamic Data

- Prefer strong types, enums, interfaces, and generic contracts over weakly
  typed `bool`, `null`, or ad-hoc string protocols when the behavior carries
  business meaning.
- Keep dynamic JSON at the boundary. This repo already uses `JsonMap`,
  `JsonAdaptor`, `Codec`, and `Converter` patterns to contain dynamic data.
- When adding or changing structured data:
  - prefer typed model objects in `lib/models/`;
  - keep JSON conversion in the model or boundary codec;
  - avoid spreading `Map<String, dynamic>` through callers.
- Follow the existing generated-model style with `json_serializable`,
  `copy_with_extension`, and adjacent `part` files when the type already uses
  that pattern.
- For workflow execution with meaningful outcomes, prefer explicit result
  contracts like `AppSyncTaskResult` over anonymous success flags.

## Storage And Data Access

- Keep SQLite and persistence concerns inside `lib/storage/`.
- Prefer going through existing storage helpers, handlers, and provider-backed
  owners instead of reading the database directly from UI code.
- If a feature already has an app-scoped access seam, route new reads and writes
  through that seam before introducing a lower-level dependency to a page.
- Use business-semantic names for runtime or calculation types. Avoid generic
  `Helper`, `Support`, or `Store` suffixes unless the type truly owns that role.

## Dart Style

- Follow `analysis_options.yaml` and the active `flutter_lints` baseline.
- Repo-specific enforced or preferred lints include:
  - explicit return types for methods;
  - final locals and final private fields when reassignment is unnecessary;
  - relative imports for files under `lib/`;
  - sorted directives and combinators;
  - enums instead of enum-like classes;
  - `StringBuffer` for incremental string assembly;
  - `const` constructors and declarations when possible;
  - avoiding unnecessary lambdas and closure parameter types.
- Write concise, technical Dart that stays readable.
- Prefer exhaustive `switch` statements or switch expressions when they make the
  state space explicit.
- Use records when they make multi-value selection or transfer clearer and stay
  local in scope.
- Prefer same-file private helpers or private extensions for local pure logic
  before introducing a new public abstraction.
- Avoid one-off generic helper layers when the real abstraction is still owned
  by a concrete model, codec, workflow, or page-local view model.

## Flutter Style

- Keep widgets immutable when possible.
- Use small, composable widgets and view models, but do not split code just to
  satisfy an arbitrary size rule.
- Keep heavy work, persistence, and workflow coordination out of `build()`.
- Keep app-shell concerns in the entry layer and page-specific logic in the page
  family.
- Prefer existing theme, localization, and navigation setup instead of
  introducing alternate app-shell patterns.
- This repo already uses `DynamicColorBuilder`, Material 3, and top-level app
  shell composition. Extend those patterns rather than bypassing them.

## Theme And Localization

- Theme setup is owned by app entry and theme-related view models.
- If a change affects theme behavior, check both the app entry wiring and the
  profile-backed theme handlers before adding new state.
- Keep custom color behavior inside the existing theme model and generated color
  pipeline.
- Localization is generated. Edit the source localization inputs, not the
  generated localization outputs.
- Use the existing normalization and generation workflow when changing l10n:
  `make normalize-l10n`, then `make gen` or the narrower needed step.

## Generated Code

- Do not hand-edit generated files unless the task explicitly requires it and no
  source-of-truth alternative exists.
- Common generated outputs in this repo include:
  - `*.g.dart` model, provider, and builder outputs;
  - localization outputs under `lib/l10n/`;
  - generated theme icon and color files under `lib/theme/_icons/` and
    `lib/theme/_colors/`;
  - generated asset accessors such as `lib/assets/assets.gen.dart`.
- Change the owning source file, annotation, config, or generator input first,
  then regenerate.

## Validation

- After changes, run the narrowest useful validation first.
- Prefer this order when applicable:
  - focused test for the touched slice;
  - focused analysis or formatting check for the touched slice;
  - generation verification when generated outputs are involved;
  - broader repo commands only when the smaller check is insufficient.
- Typical validation commands are:
  - `make format`
  - `make fix`
  - `make gen`
  - `make verify-generated`
  - `make test`
- When touching app or package generation inputs, prefer validating with the
  repo wrappers rather than raw one-off tool invocations.

## Avoid

- Do not add a second state-management approach for normal app state.
- Do not bypass existing provider or access seams from pages just because a
  lower-level object is reachable.
- Do not spread raw dynamic maps through the app when an existing typed boundary
  can own the conversion.
- Do not promote page-local logic into shared layers without clear reuse.
- Do not widen a narrow user request into unrelated refactors.
- Do not edit generated files as the primary change surface.

## References

- `README.md`
- `Makefile`
- `analysis_options.yaml`
- `pubspec.yaml`
- `lib/main.dart`
- `lib/entries/app/entry.dart`
- `lib/entries/common/app_root_view.dart`
- `lib/entries/app/providers.dart`
- `docs/wiki/Dev꞉-Build-From-Source.md`