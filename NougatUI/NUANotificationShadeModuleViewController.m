#import "NUANotificationShadeModuleViewController.h"
#import "NUANotificationShadeModuleView.h"

@implementation NUANotificationShadeModuleViewController

#pragma mark - NUANotificationShadeModuleViewController

+ (Class)viewClass {
    return NUANotificationShadeModuleView.class;
}

+ (CGFloat)defaultModuleHeight {
    return 50.0;
}

- (NSString *)moduleIdentifier {
    return @"";
}

#pragma mark - UIViewController

- (void)loadView {
    NUAPreferenceManager *notificationShadePreferences = self.notificationShadePreferences;
    NUANotificationShadeModuleView *view = [[[self.class viewClass] alloc] initWithPreferences:notificationShadePreferences];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set up defaults
    CGFloat defaultModuleHeight = [self.class defaultModuleHeight];
    _heightConstraint = [self.view.heightAnchor constraintEqualToConstant:defaultModuleHeight];
    _heightConstraint.active = YES;
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

#pragma mark - Properties

- (NUAPreferenceManager *)notificationShadePreferences {
    return [self.delegate notificationShadePreferences];
}

@end