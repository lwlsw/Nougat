#import "NUANotificationShadeContainerView.h"
#import <UIKit/_UIBackdropViewSettings+Private.h>

@implementation NUANotificationShadeContainerView

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id<NUANotificationShadeContainerViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;

        // Create backdrop view
        _UIBackdropViewSettings *blurSettings = [_UIBackdropViewSettings settingsForStyle:2030 graphicsQuality:100];
        _backdropView = [[NSClassFromString(@"_UIBackdropView") alloc] initWithFrame:frame autosizesToFitSuperview:NO settings:blurSettings];
        _backdropView.userInteractionEnabled = YES;
        _backdropView.alpha = 0;
        [self addSubview:_backdropView];

        // Add tap to dismiss
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_backdropView addGestureRecognizer:tapGestureRecognizer];

        [self _updateMasks];
    }

    return self;
}

#pragma mark - Properties

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Change alpha on backdrop (use this little trick to have it be 1 alpha at quick toggles)
    _backdropView.alpha = height / 150;

    // Force relayout of the subviews (private methods)
    [self setNeedsLayout];
    [self layoutBelowIfNeeded];
}

- (void)setChangingBrightness:(BOOL)changingBrightness {
    _changingBrightness = changingBrightness;

    // Animate view alpha
    [UIView animateWithDuration:0.25 animations:^{
        _backdropView.alpha = changingBrightness ? 0.0 : 1.0;
    }];
}

#pragma mark - View management

- (void)layoutSubviews {
    [self _updateContentFrame];
    [self _updateMasks];
}

- (void)_updateContentFrame {
    _backdropView.frame = self.bounds;
}

- (void)_updateMasks {
    // Defer expansion to view
    NUANotificationShadePanelView *panelView = [self.delegate notificationPanelForContainerView:self];
    [panelView expandHeight:self.presentedHeight];
}

#pragma mark - Gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:_backdropView];
    CGFloat yPosition = location.y;
    if (yPosition < self.presentedHeight) {
        // Tap in within panel
        return;
    }

    [self.delegate containerViewWantsDismissal:self];
}

@end