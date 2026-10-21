#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/// Registers headless plugins without attaching another set of UI lifecycle
/// delegates to the application. Method channels and other registrar APIs remain
/// owned by the underlying Flutter engine.
@interface HabitWidgetPluginRegistry : NSObject <FlutterPluginRegistry>
- (instancetype)initWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;
@end

NS_ASSUME_NONNULL_END
