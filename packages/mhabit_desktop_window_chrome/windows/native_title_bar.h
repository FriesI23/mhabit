#ifndef MHABIT_NATIVE_TITLE_BAR_H_
#define MHABIT_NATIVE_TITLE_BAR_H_

#include <windows.h>
#include <dwmapi.h>
#include <cstdint>

namespace mhabit_desktop_window_chrome {
/// Applies application caption colors while preserving the standard window frame.
///
/// Borrows the HWND without creating or destroying its window. Call from the
/// window's UI thread. Unsupported DWM attributes fall back to system colors;
/// high contrast temporarily uses the system palette and retains the app request.
class NativeTitleBar {
 public:
  /// Creates an appearance adapter, with optional native dependencies for tests.
  /// @param window Borrowed top-level window, or nullptr until Attach is called.
  /// @param set_attribute Non-null DWM setter; defaults to the system function.
  /// @param high_contrast_reader Optional high-contrast query; nullptr reads
  /// the system setting through SystemParametersInfoW.
  explicit NativeTitleBar(HWND window,
      decltype(&DwmSetWindowAttribute) set_attribute = DwmSetWindowAttribute,
      bool (*high_contrast_reader)() = nullptr)
      : window_(window), set_attribute_(set_attribute),
        high_contrast_reader_(high_contrast_reader) {}
  /// Releases appearance ownership and restores defaults if the window is alive.
  ~NativeTitleBar();

  /// Restores the old window's appearance before borrowing a different HWND.
  /// Passing the same HWND is a no-op; nullptr detaches from the old window.
  /// A new SetAppearance call is required to claim ownership of the new window.
  void Attach(HWND window);

  /// Caches and applies a palette, claiming appearance ownership on the HWND.
  ///
  /// Alpha is ignored. Color failures attempt to restore both system defaults.
  /// Once ownership is claimed, a false return does not release it: Refresh can
  /// retry the cached request after system changes, until Reset is called.
  /// @param background_argb Caption background as packed 0xAARRGGBB.
  /// @param foreground_argb Caption text as packed 0xAARRGGBB.
  /// @param dark Application dark-mode preference, applied as an optional hint.
  /// @return True only if both caption and text colors were applied; false also
  /// covers invalid windows, failed ownership, high contrast and unsupported
  /// color attributes. Failure of the optional dark-mode hint is non-fatal.
  bool SetAppearance(int64_t background_argb, int64_t foreground_argb, bool dark);

  /// Reapplies the cached request after a system appearance notification.
  /// Returns false without active ownership or a live HWND, or when high
  /// contrast/unsupported color attributes require the system palette.
  /// Failure of the optional dark-mode hint alone does not change the result.
  bool Refresh();

  /// Releases ownership and best-effort restores system colors and dark mode.
  /// Safe to repeat or call after window destruction. Refresh remains inactive
  /// until a subsequent SetAppearance call claims ownership again.
  void Reset();

  /// Converts packed 0xAARRGGBB to a Windows COLORREF, discarding alpha.
  static COLORREF ArgbToColorRef(int64_t argb);

 private:
  void ResetColors();
  HWND window_;
  decltype(&DwmSetWindowAttribute) set_attribute_;
  bool (*high_contrast_reader_)();
  COLORREF background_ = 0;
  COLORREF foreground_ = 0;
  bool dark_ = false;
  bool owned_ = false;
};
}
#endif
