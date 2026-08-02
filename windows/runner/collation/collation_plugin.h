#ifndef FLUTTER_COLLATION_PLUGIN_H_
#define FLUTTER_COLLATION_PLUGIN_H_

#include "collation_api.g.h"

#include <string>
#include <vector>

namespace mhabit_collation {

/// Windows implementation of CollationHostApi using CompareStringEx.
class CollationPlugin : public CollationHostApi {
 public:
  CollationPlugin() = default;

  /// Sorts items by collation order using CompareStringEx.
  ///
  /// Uses the locale from the request when provided, otherwise falls
  /// back to the user's default locale. Numeric values within strings
  /// are sorted naturally (SORT_DIGITSASNUMBERS).
  ErrorOr<::flutter::EncodableList> SortStrings(
      const CollationRequest& request) override;

 private:
  /// Converts a UTF-8 string to a wide string (UTF-16).
  static std::wstring ToWide(const std::string& utf8);

  /// Extracts (id, value) pairs from the request items.
  static std::vector<std::pair<std::string, std::string>> ExtractItems(
      const CollationRequest& request);
};

}  // namespace mhabit_collation

#endif  // FLUTTER_COLLATION_PLUGIN_H_
