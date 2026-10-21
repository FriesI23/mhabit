#import "HabitWidgetPluginRegistry.h"

@interface HabitWidgetPluginRegistrar : NSObject <FlutterPluginRegistrar>
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar>* registrar;
@end

@implementation HabitWidgetPluginRegistrar

- (NSObject<FlutterBinaryMessenger>*)messenger {
  return [self.registrar messenger];
}

- (NSObject<FlutterTextureRegistry>*)textures {
  return [self.registrar textures];
}

- (UIViewController*)viewController {
  return self.registrar.viewController;
}

- (void)registerViewFactory:(NSObject<FlutterPlatformViewFactory>*)factory
                    withId:(NSString*)factoryId {
  [self.registrar registerViewFactory:factory withId:factoryId];
}

- (void)registerViewFactory:(NSObject<FlutterPlatformViewFactory>*)factory
                            withId:(NSString*)factoryId
  gestureRecognizersBlockingPolicy:
      (FlutterPlatformViewGestureRecognizersBlockingPolicy)policy {
  [self.registrar registerViewFactory:factory
                              withId:factoryId
    gestureRecognizersBlockingPolicy:policy];
}

- (void)publish:(NSObject*)value {
  [self.registrar publish:value];
}

- (void)addMethodCallDelegate:(NSObject<FlutterPlugin>*)delegate
                     channel:(FlutterMethodChannel*)channel {
  [self.registrar addMethodCallDelegate:delegate channel:channel];
}

- (void)addApplicationDelegate:(NSObject<FlutterPlugin>*)delegate {
  // App-global notification/URL callbacks belong to the foreground engine. A
  // second notification delegate would invoke response completions twice.
}

- (void)addSceneDelegate:(NSObject<FlutterSceneLifeCycleDelegate>*)delegate {
  // This engine has no UI scene and only handles explicit widget operations.
}

- (NSString*)lookupKeyForAsset:(NSString*)asset {
  return [self.registrar lookupKeyForAsset:asset];
}

- (NSString*)lookupKeyForAsset:(NSString*)asset fromPackage:(NSString*)package {
  return [self.registrar lookupKeyForAsset:asset fromPackage:package];
}

- (NSObject*)valuePublishedByPlugin:(NSString*)pluginKey {
  return [self.registrar valuePublishedByPlugin:pluginKey];
}

@end

@interface HabitWidgetPluginRegistry ()
@property(nonatomic, strong) NSObject<FlutterPluginRegistry>* registry;
@property(nonatomic, strong)
    NSMutableDictionary<NSString*, HabitWidgetPluginRegistrar*>* registrars;
@end

@implementation HabitWidgetPluginRegistry

- (instancetype)initWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  self = [super init];
  if (self) {
    _registry = registry;
    _registrars = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSObject<FlutterPluginRegistrar>*)registrarForPlugin:(NSString*)pluginKey {
  HabitWidgetPluginRegistrar* registrar = self.registrars[pluginKey];
  if (registrar) return registrar;
  NSObject<FlutterPluginRegistrar>* underlying =
      [self.registry registrarForPlugin:pluginKey];
  if (!underlying) return nil;
  registrar = [[HabitWidgetPluginRegistrar alloc] init];
  registrar.registrar = underlying;
  self.registrars[pluginKey] = registrar;
  return registrar;
}

- (BOOL)hasPlugin:(NSString*)pluginKey {
  return [self.registry hasPlugin:pluginKey];
}

- (NSObject*)valuePublishedByPlugin:(NSString*)pluginKey {
  return [self.registry valuePublishedByPlugin:pluginKey];
}

@end
