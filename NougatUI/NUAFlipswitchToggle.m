#import "NUAFlipswitchToggle.h"
#import <NougatServices/NougatServices.h>
#import <UIKit/UIImage+Private.h>

@interface NUAFlipswitchToggle ()
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) FSSwitchState switchState;

@end

@implementation NUAFlipswitchToggle

- (instancetype)initWithSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _toggleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.toggleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.toggleLabel.alpha = 0.0;
        self.toggleLabel.font = [UIFont systemFontOfSize:12];
        self.toggleLabel.text = self.displayName;
        self.toggleLabel.textColor = [NUAPreferenceManager sharedSettings].textColor;
        self.toggleLabel.backgroundColor = [UIColor clearColor];
        self.toggleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.toggleLabel];

        // Constraints
        [self.toggleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.toggleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;

        // Create imageView
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];

        // Constraints
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.imageView.widthAnchor constraintEqualToConstant:28].active = YES;
        [self.imageView.heightAnchor constraintEqualToConstant:28].active = YES;

        _switchIdentifier = identifier;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; switchIdentifier = %@>", self.class, self, self.switchIdentifier];
}

#pragma mark - Ripple

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    [self toggleSwitchState];
}

#pragma mark - Toggles

- (void)toggleSwitchState {
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    NSString *flipswitchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", self.switchIdentifier];
    self.switchState = [switchPanel stateForSwitchIdentifier:flipswitchIdentifier];
    [switchPanel setState:(self.switchState == FSSwitchStateOff) ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:flipswitchIdentifier];
}

#pragma mark - Properties

- (BOOL)isUsingDark {
    return [NUAPreferenceManager sharedSettings].usingDark;
}

- (BOOL)isInverted {
    return NO;
}

- (NSBundle *)resourceBundle {
    return nil;
}

- (NSString *)displayName {
    return nil;
}

- (UIImage *)icon {
    return nil;
}

- (UIImage *)selectedIcon {
    return nil;
}

#pragma mark - Image management

- (void)_updateImageView:(BOOL)animated {
    // Get proper image
    UIImage *glyph = (self.switchState == FSSwitchStateOn) ? self.selectedIcon : self.icon;

    // Animate transition
    CGFloat duration = animated ? 0.4 : 0.0;
    [UIView transitionWithView:self.imageView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = glyph
    } completion:nil];
}

#pragma mark - Notifications

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = notification.userInfo[FSSwitchPanelSwitchIdentifierKey];
    NSString *flipswitchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", self.switchIdentifier];
    if (changedSwitch && ![changedSwitch isEqualToString:flipswitchIdentifier]) {
        return;
    }

    self.switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:flipswitchIdentifier];
    [self _updateImageView:YES];
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;

    // Update label and image
    self.toggleLabel.textColor = colorInfo[@"textColor"];
    [self _updateImageView:NO];
}

@end