#include "../native_title_bar.h"
#include "../include/mhabit_desktop_window_chrome/title_bar_ownership.h"

#include <iostream>
#include <map>
#include <set>
#include <stdexcept>
#include <vector>

using mhabit_desktop_window_chrome::NativeTitleBar;
using mhabit_desktop_window_chrome::kTitleBarAppearanceOwned;

namespace {
std::map<DWORD, DWORD> attributes;
std::map<DWORD, DWORD> applied_attributes;
bool contrast = false;
std::set<DWORD> rejected_attributes;
HRESULT WINAPI SetAttribute(HWND, DWORD attribute, LPCVOID value, DWORD size) {
  if (size != sizeof(DWORD)) return E_INVALIDARG;
  attributes[attribute] = *static_cast<const DWORD*>(value);
  if (rejected_attributes.count(attribute)) return E_INVALIDARG;
  applied_attributes[attribute] = *static_cast<const DWORD*>(value);
  return S_OK;
}
bool ReadContrast() { return contrast; }
void Check(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
}

int main() {
  HWND window = CreateWindowExW(0, L"STATIC", L"Title bar test",
      WS_OVERLAPPEDWINDOW, 0, 0, 640, 480, nullptr, nullptr,
      GetModuleHandle(nullptr), nullptr);
  if (!window) return 1;
  try {
    const auto style = GetWindowLongPtrW(window, GWL_STYLE);
    Check(NativeTitleBar::ArgbToColorRef(0xAA123456) == RGB(0x12, 0x34, 0x56),
        "ARGB to COLORREF must swap channel order and discard alpha");
    {
      NativeTitleBar title(window, SetAttribute, ReadContrast);
      Check(title.SetAppearance(0xFF112233, 0xFFEEEEEE, true), "custom colors supported");
      Check(attributes[35] == RGB(0x11, 0x22, 0x33), "caption color");
      Check(attributes[36] == RGB(0xEE, 0xEE, 0xEE), "text color");
      Check(attributes[20] == TRUE, "app dark mode independent of OS theme");
      Check(GetPropW(window, kTitleBarAppearanceOwned) != nullptr, "app ownership");
      rejected_attributes = {35, 36};
      Check(!title.SetAppearance(0xFF112233, 0xFFEEEEEE, false), "old Windows fallback");
      Check(attributes[35] == 0xFFFFFFFF && attributes[36] == 0xFFFFFFFF,
          "partial color support must restore both system colors");
      rejected_attributes.clear();
      contrast = true;
      Check(!title.Refresh(), "high contrast defers to system");
      Check(attributes[35] == 0xFFFFFFFF && attributes[36] == 0xFFFFFFFF,
          "high contrast uses system palette");
      Check(attributes[20] == FALSE, "high contrast disables immersive dark override");
      contrast = false;
      Check(title.Refresh(), "leaving high contrast restores app colors");
      Check(attributes[35] == RGB(0x11, 0x22, 0x33), "restored caption");
      Check(GetWindowLongPtrW(window, GWL_STYLE) == style, "native caption style preserved");
    }
    Check(GetPropW(window, kTitleBarAppearanceOwned) == nullptr, "cleanup releases ownership");
    Check(attributes[35] == 0xFFFFFFFF && attributes[36] == 0xFFFFFFFF, "cleanup restores defaults");

    // Model Windows 10 rejecting every newer attribute, and partial failures.
    // Track only successful writes to distinguish no-op failures from resets.
    RECT original_rect{};
    GetWindowRect(window, &original_rect);
    for (const auto& rejected : std::vector<std::set<DWORD>>{
        {20, 35, 36}, {35, 36}, {35}, {36}}) {
      attributes.clear();
      applied_attributes.clear();
      rejected_attributes = rejected;
      NativeTitleBar fallback(window, SetAttribute, ReadContrast);
      Check(!fallback.SetAppearance(0xFF123456, 0xFFEEDDCC, true),
          "unsupported/partial attributes report no exact palette");
      for (DWORD color : {35UL, 36UL}) {
        Check(attributes[color] == 0xFFFFFFFF, "both color defaults attempted");
        if (!rejected.count(color)) {
          Check(applied_attributes[color] == 0xFFFFFFFF,
              "accepted partial color override is actually undone");
        } else {
          Check(!applied_attributes.count(color), "unsupported color is a no-op");
        }
      }
      if (rejected.count(20)) {
        Check(applied_attributes.empty(), "all attributes rejected leaves system appearance untouched");
      }
      Check(!fallback.Refresh(), "system notifications safely retain fallback");
      RECT current_rect{};
      GetWindowRect(window, &current_rect);
      Check(EqualRect(&original_rect, &current_rect) &&
          GetWindowLongPtrW(window, GWL_STYLE) == style,
          "fallback preserves non-client frame, geometry and native controls");
      fallback.Reset();
      Check(GetPropW(window, kTitleBarAppearanceOwned) == nullptr,
          "fallback cleanup releases app ownership despite rejected setters");
    }
    rejected_attributes.clear();

    // Exercise real DWM on a native HWND as well as injected compatibility paths.
    NativeTitleBar native(window);
    if (native.SetAppearance(0xFF123456, 0xFFEEDDCC, true)) {
      // Caption/text colors are documented setter attributes, not getters.
      // Exact payloads are checked above; here validate real DWM acceptance.
      Check(native.Refresh(), "real DWM accepts repeated caption configuration");
      Check(GetPropW(window, kTitleBarAppearanceOwned) != nullptr, "real ownership");
    }
    native.Reset();
    Check(GetWindowLongPtrW(window, GWL_STYLE) == style, "real DWM keeps native controls");
    Check(!NativeTitleBar(nullptr).SetAppearance(0, 0, false), "missing window is safe");
    std::cout << "Native title bar: conversion, colors, all-rejected/partial fallback, contrast, ownership, DWM passed\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    DestroyWindow(window);
    return 1;
  }
  DestroyWindow(window);
  return 0;
}
