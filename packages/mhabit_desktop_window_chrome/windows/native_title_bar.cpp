#include "native_title_bar.h"

#include <dwmapi.h>
#include "include/mhabit_desktop_window_chrome/title_bar_ownership.h"

namespace mhabit_desktop_window_chrome {
namespace {
// Numeric values allow compiling against older Windows SDKs. DWM rejects
// unsupported attributes at runtime; no undocumented color APIs are used.
constexpr auto kDarkMode = static_cast<DWMWINDOWATTRIBUTE>(20);
constexpr auto kCaptionColor = static_cast<DWMWINDOWATTRIBUTE>(35);
constexpr auto kTextColor = static_cast<DWMWINDOWATTRIBUTE>(36);
constexpr COLORREF kDefaultColor = 0xFFFFFFFF;

bool HighContrast() {
  HIGHCONTRASTW contrast{};
  contrast.cbSize = sizeof(contrast);
  return SystemParametersInfoW(SPI_GETHIGHCONTRAST, sizeof(contrast), &contrast, 0)
      && (contrast.dwFlags & HCF_HIGHCONTRASTON) != 0;
}

BOOL SystemDarkMode() {
  DWORD light = 1;
  DWORD size = sizeof(light);
  RegGetValueW(HKEY_CURRENT_USER,
      L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
      L"AppsUseLightTheme", RRF_RT_REG_DWORD, nullptr, &light, &size);
  return !HighContrast() && light == 0;
}

}

void NativeTitleBar::ResetColors() {
  set_attribute_(window_, kCaptionColor, &kDefaultColor, sizeof(kDefaultColor));
  set_attribute_(window_, kTextColor, &kDefaultColor, sizeof(kDefaultColor));
}

NativeTitleBar::~NativeTitleBar() { Reset(); }

void NativeTitleBar::Attach(HWND window) {
  if (window == window_) return;
  Reset();
  window_ = window;
}

COLORREF NativeTitleBar::ArgbToColorRef(int64_t argb) {
  return RGB((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);
}

bool NativeTitleBar::SetAppearance(int64_t background_argb,
                                  int64_t foreground_argb, bool dark) {
  if (!IsWindow(window_)) return false;
  background_ = ArgbToColorRef(background_argb);
  foreground_ = ArgbToColorRef(foreground_argb);
  dark_ = dark;
  if (!SetPropW(window_, kTitleBarAppearanceOwned, reinterpret_cast<HANDLE>(1))) {
    return false;
  }
  owned_ = true;
  return Refresh();
}

bool NativeTitleBar::Refresh() {
  if (!owned_ || !IsWindow(window_)) return false;
  const bool high_contrast = high_contrast_reader_ ? high_contrast_reader_() : HighContrast();
  const BOOL dark = !high_contrast && dark_;
  set_attribute_(window_, kDarkMode, &dark, sizeof(dark));
  if (high_contrast) {
    ResetColors();
    return false;
  }
  const HRESULT background = set_attribute_(
      window_, kCaptionColor, &background_, sizeof(background_));
  const HRESULT foreground = set_attribute_(
      window_, kTextColor, &foreground_, sizeof(foreground_));
  if (FAILED(background) || FAILED(foreground)) {
    ResetColors();
    return false;
  }
  return true;
}

void NativeTitleBar::Reset() {
  if (!owned_) return;
  owned_ = false;
  if (!IsWindow(window_)) return;
  RemovePropW(window_, kTitleBarAppearanceOwned);
  ResetColors();
  const BOOL dark = SystemDarkMode();
  set_attribute_(window_, kDarkMode, &dark, sizeof(dark));
}
}
