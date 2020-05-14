#import "NUANotificationTableViewCell.h"
#import "NUARippleButton.h"
#import <MobileCoreServices/LSApplicationProxy.h>
#import <UIKit/UIView+Internal.h>
#import <Macros.h>

@interface NUANotificationTableViewCell ()
@property (strong, nonatomic) UIImageView *attachmentImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) NUARelativeDateLabel *dateLabel;
@property (strong, nonatomic) UIView *optionsBar;
@property (strong, nonatomic) NUARippleButton *openButton;
@property (strong, nonatomic) NUARippleButton *clearButton;

@property (strong, nonatomic) NSLayoutConstraint *attachmentConstraint;
@property (strong, nonatomic) NSLayoutConstraint *optionsHeightConstraint;
@property (strong, nonatomic) UIPanGestureRecognizer *expandGestureRecognizer;

@end

@implementation NUANotificationTableViewCell

#pragma mark - Dealloc

- (void)dealloc {
    // Reuse date label
    [self _recycleDateLabel];
}

#pragma mark - View Creation

- (void)_configureAttachmentImageViewIfNecessary {
    if (self.attachmentImageView) {
        // Already exists
        return;
    }

    // Create
    self.attachmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.attachmentImageView.clipsToBounds = YES;
    self.attachmentImageView._continuousCornerRadius = 3.0;
    self.attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.attachmentImageView];

    // Constraints
    [self.attachmentImageView.topAnchor constraintEqualToAnchor:self.headerStackView.bottomAnchor].active = YES;
    [self.attachmentImageView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.attachmentImageView.heightAnchor constraintEqualToConstant:40.0].active = YES;
    self.attachmentConstraint = [self.attachmentImageView.widthAnchor constraintEqualToConstant:0.0];
    self.attachmentConstraint.active = YES;
}

- (void)_configureDateLabelIfNecessary {
    if (self.dateLabel) {
        // View already exists, or no notification
        return;
    }

    // Create date label
    self.dateLabel = [[NUADateLabelRepository sharedRepository] startLabelWithStartDate:self.timestamp timeZone:self.notification.timeZone];
    self.dateLabel.delegate = self;
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.dateLabel.textColor = [UIColor grayColor];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Add to header stack
    [self.headerStackView insertArrangedSubview:self.dateLabel atIndex:3];
}

- (void)_configureTitleLabelIfNecessary {
    if (self.titleLabel) {
        // Already exists, or no attachment yet
        return;
    }

    // Create
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Here we actually wanna use iOS 13's label color since the background will automatically change regardless of settings
    if (@available(iOS 13, *)) {
        // To silence warnings
        self.titleLabel.textColor = [UIColor labelColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    [self.contentView addSubview:self.titleLabel];

    [self.titleLabel.firstBaselineAnchor constraintEqualToAnchor:self.headerStackView.bottomAnchor constant:20.0].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.headerStackView.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_configureMessageLabelIfNecessary {
    if (self.messageLabel) {
        // Already exists, or no attachment yet
        return;
    }

    // Create
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.messageLabel.numberOfLines = 2;
    self.messageLabel.textColor = [UIColor grayColor];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageLabel];

    [self.messageLabel.firstBaselineAnchor constraintEqualToAnchor:self.titleLabel.lastBaselineAnchor constant:20.0].active = YES;
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor].active = YES;
    [self.messageLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.attachmentImageView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_configureOptionsBarIfNecessary {
    if (self.optionsBar) {
        // Already exists
        return;
    }

    // Create bar
    self.optionsBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.optionsBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.optionsBar];

    if (@available(iOS 13, *)) {
        // Make options depend on light/dark
        BOOL inDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        self.optionsBar.backgroundColor = inDarkMode ? PixelBackgroundColor : OreoBackgroundColor;
    } else {
        // Always light
        self.optionsBar.backgroundColor = OreoBackgroundColor;
    }

    // Constraints
    [self.optionsBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.optionsBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;

    [self.optionsBar.topAnchor constraintEqualToAnchor:self.messageLabel.lastBaselineAnchor constant:15.0].active = YES;
    self.optionsHeightConstraint = [self.optionsBar.heightAnchor constraintEqualToConstant:0.0];
    self.optionsHeightConstraint.active = YES;

    // Have cell height be determined by size of everything else
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;

    // Create buttons
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *localizedOpen = [bundle localizedStringForKey:@"OPEN" value:@"Open" table:@"Localizable"];
    self.openButton = [[NUARippleButton alloc] init];
    [self.openButton addTarget:self action:@selector(cellOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.openButton setTitle:localizedOpen forState:UIControlStateNormal];
    self.openButton.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.openButton.hidden = YES;
    self.openButton.maxRippleRadius = 20.0;
    self.openButton.rippleStyle = NUARippleStyleUnbounded;
    self.openButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.openButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.openButton sizeToFit];
    [self.optionsBar addSubview:self.openButton];

    NSString *localizedClear = [bundle localizedStringForKey:@"CLEAR" value:@"Clear" table:@"Localizable"];
    self.clearButton = [[NUARippleButton alloc] init];
    [self.clearButton addTarget:self action:@selector(cellClearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setTitle:localizedClear forState:UIControlStateNormal];
    self.clearButton.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.clearButton.hidden = YES;
    self.clearButton.maxRippleRadius = 20.0;
    self.clearButton.rippleStyle = NUARippleStyleUnbounded;
    self.clearButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearButton sizeToFit];
    [self.optionsBar addSubview:self.clearButton];

    // Constraints
    [self.openButton.leadingAnchor constraintEqualToAnchor:self.messageLabel.leadingAnchor].active = YES;
    [self.openButton.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.openButton.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;

    [self.clearButton.leadingAnchor constraintEqualToAnchor:self.openButton.trailingAnchor constant:30.0].active = YES;
    [self.clearButton.topAnchor constraintEqualToAnchor:self.optionsBar.topAnchor].active = YES;
    [self.clearButton.bottomAnchor constraintEqualToAnchor:self.optionsBar.bottomAnchor].active = YES;
}

#pragma mark - Buttons

- (void)cellOpenButtonPressed:(NUARippleButton *)button {
    // Defer to delegate
    [self.actionsDelegate notificationTableViewCellRequestsExecuteDefaultAction:self];
}

- (void)cellClearButtonPressed:(NUARippleButton *)button {
    // Defer to delegate
    [self.actionsDelegate notificationTableViewCellRequestsExecuteAlternateAction:self];
}

#pragma mark - Gesture Recognizer

- (void)_handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        // Only trigger on end
        return;
    }

    // Determine if up or down
    CGPoint velocity = [gestureRecognizer velocityInView:self.contentView];
    BOOL expand = velocity.y > 0;
    [self.delegate tableViewCell:self wantsExpansion:expand];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        // Not dealing with pans
        return NO;
    }

    // Only expand under certain criteria
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint velocity = [panGestureRecognizer velocityInView:self.contentView];
    if (fabs(velocity.x) > fabs(velocity.y)) {
        // Horizontal pan, don't do anything
        return NO;
    }

    CGPoint location = [panGestureRecognizer locationInView:self.contentView];
    CGFloat labelHeight = CGRectGetHeight(self.contentView.bounds);
    CGFloat projectedY = location.y + [self project:velocity.y decelerationRate:0.998];
    return (fabs(projectedY) < (labelHeight * 1.69));
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Conflict with table scroll
    return (gestureRecognizer == self.expandGestureRecognizer) && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

- (CGFloat)project:(CGFloat)initialVelocity decelerationRate:(CGFloat)decelerationRate {
    // From WWDC (UIScrollView.decelerationRate = 0.998)
    return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

#pragma mark - Properties

- (void)setUILocked:(BOOL)UILocked {
    if (_UILocked == UILocked) {
        // Nothing to change
        return;
    }

    _UILocked = UILocked;

    // Change and hide stuff
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *hiddenTitleText = [bundle localizedStringForKey:@"NOTIFICATION" value:@"Notification" table:@"Localizable"];
    NSString *realTitleText = self.notification.title ?: self.notification.message;
    self.titleText = UILocked ? hiddenTitleText : realTitleText;
    self.messageLabel.hidden = UILocked;
    self.attachmentImageView.hidden = UILocked;
}

- (NSString *)titleText {
    return self.titleLabel.text;
}

- (void)setTitleText:(NSString *)titleText {
    if ([self.titleLabel.text isEqualToString:titleText]) {
        // Same string
        return;
    }

    // Create if needed
    [self _configureTitleLabelIfNecessary];

    // Update
    self.titleLabel.text = titleText;
    [self setNeedsLayout];
}

- (NSString *)messageText {
    return self.messageLabel.text;
}

- (void)setMessageText:(NSString *)messageText {
    if ([self.messageLabel.text isEqualToString:messageText]) {
        // Same string
        return;
    }

    // Create if needed
    [self _configureMessageLabelIfNecessary];

    // Update
    self.messageLabel.text = messageText;

    // Manually derive message label
    CGRect contentViewBounds = UIEdgeInsetsInsetRect(self.contentView.bounds, self.contentView.layoutMargins);
    CGFloat trailingInset = (self.attachmentImage) ? 50.0 : 10.0;
    CGFloat calculatedLabelWidth = CGRectGetWidth(contentViewBounds) - trailingInset;
    CGSize boundingSize = CGSizeMake(calculatedLabelWidth, CGFLOAT_MAX);

    // Determine if expandable
    CGRect requiredLabelBounds = [messageText boundingRectWithSize:boundingSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: self.messageLabel.font} context:nil];
    self.expandable = floor(CGRectGetHeight(requiredLabelBounds) / self.messageLabel.font.lineHeight) > 2;
    [self setNeedsLayout];
}

- (UIImage *)attachmentImage {
    return self.attachmentImageView.image;
}

- (void)setAttachmentImage:(UIImage *)attachmentImage {
    if (attachmentImage && self.attachmentImageView.image == attachmentImage) {
        // Same image
        return;
    }

    // Create if needed
    [self _configureAttachmentImageViewIfNecessary];

    // Update image
    self.attachmentImageView.image = attachmentImage;
    CGFloat constant = (attachmentImage != nil) ? 40.0 : 0.0;
    self.attachmentConstraint.constant = constant;

    [self setNeedsLayout];
}

- (void)setTimestamp:(NSDate *)timestamp {
    if ([_timestamp isEqual:timestamp]) {
        // Same date
        return;
    }

    // Recreate
    _timestamp = timestamp;
    [self _tearDownDateLabel];
    [self _configureDateLabelIfNecessary];
    [self setNeedsLayout];
}

- (void)setExpandable:(BOOL)expandable {
    [super setExpandable:expandable];

    if (expandable && !self.expandGestureRecognizer) {
        // Add gesture
        self.expandGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        self.expandGestureRecognizer.delegate = self;
        [self.contentView addGestureRecognizer:self.expandGestureRecognizer];
    } else if (!expandable && self.expandGestureRecognizer) {
        // Remove gesture
        [self.contentView removeGestureRecognizer:self.expandGestureRecognizer];
        self.expandGestureRecognizer.delegate = nil;
        self.expandGestureRecognizer = nil;
    }
}

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

    [self _configureOptionsBarIfNecessary];

    if (!self.expandable) {
        // No change, or not allowed
        return;
    }

    // Configure constraints 
    self.optionsHeightConstraint.constant = expanded ? 40.0 : 0.0;

    // Configure message label
    self.messageLabel.numberOfLines = expanded ? 0 : 2;

    // Configure buttons
    self.openButton.hidden = !self.expanded;
    self.clearButton.hidden = !self.expanded;
    [self setNeedsLayout];
}

- (void)setNotification:(NUACoalescedNotification *)notification {
    if ([notification isEqual:_notification]) {
        // Same notification
        return;
    }

    // Configure content
    _notification = notification;
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *titleText = notification.title ?: notification.message;
    NSString *hiddenTitleText = [bundle localizedStringForKey:@"NOTIFICATION" value:@"Notification" table:@"Localizable"];
    NSString *fallbackMessage = [bundle localizedStringForKey:@"TAP_FOR_MORE_OPTIONS" value:@"Tap for more options." table:@"Localizable"];
    NSString *messageText = (notification.title) ? notification.message : fallbackMessage;
    self.attachmentImage = notification.attachmentImage;
    self.titleText = self.UILocked ? hiddenTitleText : titleText;
    self.messageText = messageText;
    self.headerGlyph = notification.icon;
    self.timestamp = notification.timestamp;

    // // Update header text
    [self updateHeaderWithSectionID:notification.sectionID];

    // // Get our color info
    [self updateColorInfoFromNotification:notification];
}

#pragma mark - Header Text

- (void)updateHeaderWithSectionID:(NSString *)sectionID {
    NSString *displayName;
    if ([sectionID isEqualToString:@"Screen Recording"] || [sectionID isEqualToString:@"com.apple.ReplayKitNotifications"]) {
        // Exception for screen recording, since it doesnt use a conventional bundle id
        // Get translation from CC bundle
        NSBundle *screenRecordingBundle = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle"];
        displayName = [screenRecordingBundle localizedStringForKey:@"CFBundleDisplayName" value:@"Screen Recording" table:@"InfoPlist"];
    } else {
        // Too lazy/complicated to link against (Mobile)CoreServices
        LSApplicationProxy *applicationProxy = [NSClassFromString(@"LSApplicationProxy") applicationProxyForIdentifier:sectionID];
        displayName = applicationProxy.localizedName;
    }

    self.headerText = displayName;
}

#pragma mark - Date Label

- (void)dateLabelDidChange:(NUARelativeDateLabel *)dateLabel {
    // Resize and reload
    [self.dateLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)_tearDownDateLabel {
    [UIView performWithoutAnimation:^{
        if (!self.dateLabel) {
            // No label
            return;
        }

        // Recycle
        [self.dateLabel removeFromSuperview];
        [self _recycleDateLabel];
        _dateLabel = nil;
    }];
}

- (void)_recycleDateLabel {
    // Recycle
    self.dateLabel.delegate = nil;
    [[NUADateLabelRepository sharedRepository] recycleLabel:self.dateLabel];
}

#pragma mark - Color Info

- (void)updateColorInfoFromNotification:(NUACoalescedNotification *)notification {
    // Check if info is cached or not
    NUAImageColorCache *colorCache = [NUAImageColorCache sharedCache];
    UIImage *iconImage = notification.icon;
    if ([colorCache hasColorDataForImage:iconImage type:NUAImageColorInfoTypeAppIcon]) {
        // Has data
        NUAImageColorInfo *colorInfo = [colorCache cachedColorInfoForImage:iconImage type:NUAImageColorInfoTypeAppIcon];
        [self _updateWithColorInfo:colorInfo];
    } else {
        // Generate new info
        [colorCache cacheColorInfoForImage:iconImage type:NUAImageColorInfoTypeAppIcon completion:^(NUAImageColorInfo *colorInfo) {
            [self _updateWithColorInfo:colorInfo];
        }];
    }
}

- (void)_updateWithColorInfo:(NUAImageColorInfo *)colorInfo {
    // Update header
    self.headerTint = colorInfo.primaryColor;

    // Update buttons
    [self _configureOptionsBarIfNecessary];
    [self.openButton setTitleColor:colorInfo.primaryColor forState:UIControlStateNormal];
    [self.clearButton setTitleColor:colorInfo.primaryColor forState:UIControlStateNormal];
    [self setNeedsLayout];
}

#pragma mark - Appearance Updates

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    // Check if appearance changed
    if (@available(iOS 13, *)) {
        if (![self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            return;
        }

        // Change option bar color to match system
        BOOL inDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        UIColor *optionsBackgroundColor = inDarkMode ? PixelBackgroundColor : OreoBackgroundColor;
        self.optionsBar.backgroundColor = optionsBackgroundColor;
    }
}

@end