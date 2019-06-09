#import <UIKit/UIKit.h>
#import "NUAToggleInfo.h"

typedef NS_ENUM(NSUInteger, NUADrawerTheme) {
    NUADrawerThemeNexus,
    NUADrawerThemePixel,
    NUADrawerThemeOreo
};

// Settings keys
static NSString *const NUAPreferencesEnabledKey = @"enabled";

static NSString *const NUAPreferencesTogglesListKey = @"togglesList";

static NSString *const NUAPreferencesCurrentThemeKey = @"darkVariant";

@interface NUAPreferenceManager : NSObject
@property (class, strong, readonly) NUAPreferenceManager *sharedSettings;

@property (assign, readonly, nonatomic) BOOL enabled;
@property (getter=isUsingDark, readonly, nonatomic) BOOL usingDark;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (strong, readonly, nonatomic) UIColor *textColor;
@property (copy, readonly, nonatomic) NSArray<NSString *> *enabledToggles;
@property (copy, readonly, nonatomic) NSArray<NSString *> *disabledToggles;


- (NSArray<NSString *> *)_installedToggleIdentifiers;
- (NUAToggleInfo *)toggleInfoForIdentifier:(NSString *)identifier;
- (void)refreshToggleInfo;

+ (NSString *)carrierName;

@end