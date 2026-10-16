#ifndef MHABIT_TITLE_BAR_OWNERSHIP_H_
#define MHABIT_TITLE_BAR_OWNERSHIP_H_

namespace mhabit_desktop_window_chrome {
/// HWND property marking application ownership of title-bar appearance.
/// Presence tells Runner to leave appearance updates to the plugin, including
/// when exact colors are unavailable or high contrast uses system colors.
/// NativeTitleBar sets the property when claiming ownership and removes it on
/// Reset/destruction; the property value itself carries no appearance data.
inline constexpr wchar_t kTitleBarAppearanceOwned[] =
    L"mhabit.desktop_window_chrome.titleBarAppearanceOwned";
}
#endif
