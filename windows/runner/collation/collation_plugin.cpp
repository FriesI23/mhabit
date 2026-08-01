#include "collation_plugin.h"

#include <windows.h>

#include <algorithm>
#include <string>
#include <utility>
#include <vector>

namespace mhabit_collation {

namespace {

/// Compares two wide strings using CompareStringEx.
int CompareWide(const std::wstring &a, const std::wstring &b,
                const wchar_t *locale_name) {
  return CompareStringEx(locale_name, NORM_IGNORECASE | SORT_DIGITSASNUMBERS,
                         a.c_str(), static_cast<int>(a.length()), b.c_str(),
                         static_cast<int>(b.length()), nullptr, nullptr, 0);
}

} // namespace

std::wstring CollationPlugin::ToWide(const std::string &utf8) {
  if (utf8.empty())
    return {};
  int len = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(),
                                static_cast<int>(utf8.length()), nullptr, 0);
  if (len <= 0)
    return {};
  std::wstring wide(static_cast<size_t>(len), L'\0');
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), static_cast<int>(utf8.length()),
                      &wide[0], len);
  return wide;
}

std::vector<std::pair<std::string, std::string>>
CollationPlugin::ExtractItems(const CollationRequest &request) {
  std::vector<std::pair<std::string, std::string>> items;
  const auto &raw = request.items();
  items.reserve(raw.size());
  for (const auto &encodable : raw) {
    const auto &item = std::any_cast<const CollationItem &>(
        std::get<::flutter::CustomEncodableValue>(encodable));
    items.emplace_back(item.id(), item.value());
  }
  return items;
}

ErrorOr<::flutter::EncodableList>
CollationPlugin::SortStrings(const CollationRequest &request) {
  struct SortEntry {
    std::string id;
    std::wstring wide_value;
  };

  auto raw = ExtractItems(request);
  std::vector<SortEntry> entries;
  entries.reserve(raw.size());
  for (auto &item : raw) {
    entries.push_back(
        {std::move(item.first), ToWide(item.second)});
  }

  // Resolve locale: use requested locale when available, otherwise
  // fall back to the user's default locale.
  const auto *locale_str = request.locale();
  std::wstring locale_name;
  if (locale_str && !locale_str->empty()) {
    // Dart localeName uses underscores (zh_Hans_CN); BCP-47 / Windows
    // expects hyphens (zh-Hans-CN).  Normalize to BCP-47 here, matching
    // the Android path.
    std::string bcp47 = *locale_str;
    std::replace(bcp47.begin(), bcp47.end(), '_', '-');
    locale_name = ToWide(bcp47);
  }
  // No explicit locale: pass LOCALE_NAME_USER_DEFAULT (nullptr) so
  // CompareStringEx uses the user's default locale.
  const wchar_t *effective_locale =
      locale_name.empty() ? LOCALE_NAME_USER_DEFAULT : locale_name.c_str();

  // Sort by collation order (using pre-converted wide strings),
  // then by id as tie-break for consistency with other platforms.
  std::stable_sort(entries.begin(), entries.end(),
                   [effective_locale](const auto &a, const auto &b) {
                     int cmp = CompareWide(a.wide_value, b.wide_value,
                                           effective_locale);
                     if (cmp == CSTR_LESS_THAN)
                       return true;
                     if (cmp == CSTR_GREATER_THAN)
                       return false;
                     return a.id < b.id;
                   });

  ::flutter::EncodableList result;
  result.reserve(entries.size());
  for (const auto &e : entries) {
    result.push_back(::flutter::EncodableValue(e.id));
  }
  return result;
}

} // namespace mhabit_collation
