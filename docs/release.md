# Pre-Released: pre-v1.27.19+208

## ✨ Features

- Add shared support cards to Settings and optional startup reminders, with
  animated headers, automatic paging and clickable page indicators. Keep GitHub
  Star and donation actions, and offer store review or Flathub favorites links
  for the current distribution. Remember **Remind me later** and **Don't remind
  me again** choices (#707)
- Choose and remember the interface style in Display settings. When using the
  Apple style, choose automatic, inset or edge Sidebar appearance (#709)

## 🐛 Fixes

- Restore normal browsing after an empty search in the Apple interface (#703)
- Restore WebDAV sync with mixed authentication challenges, including Fastmail
  (#705)
- Preserve Loop import history for habits with non-Latin names and retain record
  notes (#706)
- Refresh support cards and open previews when their channel changes, and keep
  background support controls visually enabled while a dialog is open (#707)
- Restore startup support reminders on Windows and Linux, and close the support
  dialog before asking for sync confirmation (#708)
- Preserve habit-page floating button transitions after switching interface
  styles (#709)
- Keep the macOS app category consistent with the category selected in Xcode
  (#711)

## 🌐 Localization

- Update Arabic translation, thanks to Rostom HEO's contribution on Weblate
  (#702)
- Update Spanish translation, thanks to Jesus Calle's contribution on Weblate
  (#710)
- Update Welsh translation, thanks to Jon Stevenson's contribution on Weblate
  (store metadata, #710)
- Update Esperanto translation, thanks to Jon Stevenson's contribution on Weblate
  (store metadata, #710)
- Prepare Welsh and Esperanto app locales, currently available only in debug
  builds. Untranslated app text falls back to English (#711)

## 🧹 Others

- Move community planning and feedback links to GitHub Projects and Issue forms
- Add links to related projects and refresh donor and translator credits
- Refresh the Flutter version badge and document SDK upgrade rules

[Full Changelog](https://github.com/FriesI23/mhabit/compare/v1.27.18+207...pre-v1.27.19+208)
