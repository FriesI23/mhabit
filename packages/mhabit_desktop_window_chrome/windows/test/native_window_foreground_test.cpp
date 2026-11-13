#include "../native_window_foreground.h"

#include <iostream>
#include <stdexcept>

using mhabit_desktop_window_chrome::NativeWindowForeground;

namespace {
bool native_foreground = false;
int reads = 0;
bool ReadForeground(HWND) {
  ++reads;
  return native_foreground;
}
void Check(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
}  // namespace

int main() {
  try {
    NativeWindowForeground foreground(ReadForeground);
    Check(!foreground.OnMessage(nullptr, WM_SHOWWINDOW, TRUE),
          "show announcement must not publish before native visibility commits");
    Check(reads == 0, "show announcement must not sample premature visibility");
    Check(foreground.OnMessage(nullptr, WM_WINDOWPOSCHANGED, 0) == false,
          "hidden window stays outside foreground");
    Check(!foreground.OnMessage(nullptr, WM_WINDOWPOSCHANGED, 0),
          "duplicate hidden state is not published");

    // A cold start may commit visibility without another focus message.
    native_foreground = true;
    Check(foreground.OnMessage(nullptr, WM_WINDOWPOSCHANGED, 0) == true,
          "committed show must publish without a later focus event");
    Check(!foreground.OnMessage(nullptr, WM_ACTIVATE, WA_ACTIVE),
          "duplicate activation is not published");
    const int reads_before_deactivation = reads;
    Check(foreground.OnMessage(nullptr, WM_ACTIVATE, WA_INACTIVE) == false,
          "deactivation is false even before native focus changes");
    Check(reads == reads_before_deactivation,
          "deactivation does not trust a stale positive sample");
    Check(foreground.OnMessage(nullptr, WM_ACTIVATE, WA_ACTIVE) == true,
          "activation samples actual foreground");
    Check(foreground.OnMessage(nullptr, WM_SIZE, SIZE_MINIMIZED) == false,
          "minimization is immediately false");
    native_foreground = false;
    Check(!foreground.OnMessage(nullptr, WM_SIZE, SIZE_RESTORED),
          "restoration cannot publish a background window as foreground");
    native_foreground = true;
    Check(foreground.OnMessage(nullptr, WM_SIZE, SIZE_RESTORED) == true,
          "restoration can publish verified foreground");
    Check(foreground.OnMessage(nullptr, WM_SHOWWINDOW, FALSE) == false,
          "hide announcement is immediately false");
    Check(foreground.OnMessage(nullptr, WM_WINDOWPOSCHANGED, 0) == true,
          "later committed foreground is sampled again");
    Check(foreground.OnMessage(nullptr, WM_DESTROY, 0) == false,
          "destruction is immediately false");
    const int reads_before_unrelated = reads;
    Check(!foreground.OnMessage(nullptr, WM_PAINT, 0),
          "unrelated messages do not publish");
    Check(reads == reads_before_unrelated,
          "unrelated messages do not query foreground");
    Check(!NativeWindowForeground::ReadForeground(nullptr),
          "an unavailable window cannot be foreground");
    std::cout << "Native foreground: committed show, activation, hide, minimize, deduplication passed\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  return 0;
}
