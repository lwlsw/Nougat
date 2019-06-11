#import "NUATogglesContentView.h"
#import <NougatServices/NougatServices.h>
#import <Macros.h>

@interface NUATogglesContentView ()
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> *heightConstraints;
@property (strong, nonatomic) NSMutableArray<NSLayoutConstraint *> *widthConstraints;
@property (strong, nonatomic) NSLayoutConstraint *topLeftInsetConstraint;
@property (strong, nonatomic) NSLayoutConstraint *middleTopInsetConstraint;
@property (strong, nonatomic) NSLayoutConstraint *middleRightInsetConstraint;

@property (strong, nonatomic) UIStackView *topStackView;
@property (strong, nonatomic) UIStackView *middleStackView;
@property (strong, nonatomic) UIStackView *bottomStackView;

@end

@implementation NUATogglesContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Load instance manager
        _togglesProvider = [NUAToggleInstancesProvider defaultProvider];

        // Set properties
        _arranged = NO;
        self.heightConstraints = [NSMutableArray array];
        self.widthConstraints = [NSMutableArray array];

        // Populate Toggles
        [self _populateToggles];
    }

    return self;
}

#pragma mark - Toggles management

- (void)_populateToggles {
    self.togglesArray = self.togglesProvider.toggleInstances;

    for (NUAFlipswitchToggle *toggle in self.togglesArray) {
        toggle.delegate = self;
    }

    if (self.togglesArray.count > 6) {
        _topRow = [self.togglesArray subarrayWithRange:NSMakeRange(0, 3)]; // First 3
        _middleRow = [self.togglesArray subarrayWithRange:NSMakeRange(3 , 3)]; // Middle 3
        _bottomRow = [self.togglesArray subarrayWithRange:NSMakeRange(6, self.togglesArray.count - 6)];
    } else if (self.togglesArray.count > 3) {
        _topRow = [self.togglesArray subarrayWithRange:NSMakeRange(0, 3)]; // First 3
        _middleRow = [self.togglesArray subarrayWithRange:NSMakeRange(3 , self.togglesArray.count - 3)]; 
    } else {
        _topRow = self.togglesArray;
    }
}

- (void)_layoutToggles {
    if (self.arranged) {
        return;
    }

    // Create containers
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat containerWidth = viewWidth / 2;
    CGFloat bottomWidth = (viewWidth - 70);

    self.topStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.topStackView.axis = UILayoutConstraintAxisHorizontal;
    self.topStackView.alignment = UIStackViewAlignmentFill;
    self.topStackView.distribution = UIStackViewDistributionFillEqually;
    self.topStackView.spacing = 0.0;
    self.topStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.topStackView];

    [self.topStackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;

    self.topLeftInsetConstraint = [self.topStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0];
    self.topLeftInsetConstraint.active = YES;

    NSLayoutConstraint *widthConstraint = [self.topStackView.widthAnchor constraintEqualToConstant:containerWidth];
    widthConstraint.active = YES;
    [self.widthConstraints addObject:widthConstraint];

    NSLayoutConstraint *heightConstraint = [self.topStackView.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.bounds)];
    heightConstraint.active = YES;
    [self.heightConstraints addObject:heightConstraint];

    for (NUAFlipswitchToggle *toggle in _topRow) {
        [self.topStackView addArrangedSubview:toggle];
    }

    if (_middleRow) {
        [self _createMiddleRow];
    }

    if (_bottomRow) {
        [self _createBottomRow];
    }

    _startingWidth = containerWidth;
    _widthDifference = bottomWidth - containerWidth;

    _arranged = YES;
}

- (void)_createMiddleRow {
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat containerWidth = viewWidth / 2;

    self.middleStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.middleStackView.axis = UILayoutConstraintAxisHorizontal;
    self.middleStackView.alignment = UIStackViewAlignmentFill;
    self.middleStackView.distribution = UIStackViewDistributionFillEqually;
    self.middleStackView.spacing = 0.0;
    self.middleStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.middleStackView];

    self.middleTopInsetConstraint = [self.middleStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0];
    self.middleTopInsetConstraint.active = YES;

    self.middleRightInsetConstraint = [self.middleStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0];
    self.middleRightInsetConstraint.active = YES;

    NSLayoutConstraint *widthConstraint = [self.middleStackView.widthAnchor constraintEqualToConstant:containerWidth];
    widthConstraint.active = YES;
    [self.widthConstraints addObject:widthConstraint];

    NSLayoutConstraint *heightConstraint = [self.middleStackView.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.bounds)];
    heightConstraint.active = YES;
    [self.heightConstraints addObject:heightConstraint];

    for (NUAFlipswitchToggle *toggle in _middleRow) {
        [self.middleStackView addArrangedSubview:toggle];
    }
}

- (void)_createBottomRow {
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat bottomWidth = (viewWidth - 70);

    self.bottomStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.bottomStackView.axis = UILayoutConstraintAxisHorizontal;
    self.bottomStackView.alignment = UIStackViewAlignmentFill;
    self.bottomStackView.distribution = UIStackViewDistributionFillEqually;
    self.bottomStackView.spacing = 0.0;
    self.bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bottomStackView];

    [self.bottomStackView.topAnchor constraintEqualToAnchor:self.middleStackView.bottomAnchor].active = YES;
    [self.bottomStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:35].active = YES;
    [self.bottomStackView.widthAnchor constraintEqualToConstant:bottomWidth].active = YES;

    NSLayoutConstraint *heightConstraint = [self.bottomStackView.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.bounds)];
    heightConstraint.active = YES;
    [self.heightConstraints addObject:heightConstraint];

    for (NUAFlipswitchToggle *toggle in _bottomRow) {
        [self.bottomStackView addArrangedSubview:toggle];
        toggle.alpha = 0.0;
    }
}

- (void)refreshToggleLayout {
    _arranged = NO;

    // Reset arrays and views
    _topRow = nil;
    _middleRow = nil;
    _bottomRow = nil;

    [self.topStackView removeFromSuperview];
    [self.middleStackView removeFromSuperview];
    [self.bottomStackView removeFromSuperview];

    self.topStackView = nil;
    self.middleStackView = nil;
    self.bottomStackView = nil;

    // Populate and relayout
    [self _populateToggles];
    [self _layoutToggles];
}

#pragma mark - Rearrangement

- (void)rearrangeForPercent:(CGFloat)percent {
    // Update top inset
    self.middleTopInsetConstraint.constant = 100 * percent;

    // Update left and right inset
    self.topLeftInsetConstraint.constant = 35 * percent;
    self.middleRightInsetConstraint.constant = -35 * percent;

    // Update width
    for (NSLayoutConstraint *constraint in self.widthConstraints) {
        constraint.constant = _startingWidth + (_widthDifference * percent);
    }

    // Update height
    for (NSLayoutConstraint *constraint in self.heightConstraints) {
        constraint.constant = 50 + (50 * percent);
    }
}

#pragma mark - Delegate

- (void)toggleWantsNotificationShadeDismissal:(NUAFlipswitchToggle *)toggle {
    [self.delegate contentViewWantsNotificationShadeDismissal:self];
}

#pragma mark - Properties

- (void)setExpandedPercent:(CGFloat)percent {
    _expandedPercent = percent;

    [self rearrangeForPercent:percent];

    if (percent < 0.75 && percent != 0.0) {
        // Allow 0.0 becaue that is passed or reset purposes
        return;
    }

    // Delay appearance of labels
    CGFloat adjustedPercent = (percent - 0.75) * 4;
    for (NUAFlipswitchToggle *toggle in self.togglesArray) {
        toggle.toggleLabel.alpha = adjustedPercent;

        if (!_bottomRow || ![_bottomRow containsObject:toggle]) {
            continue;
        }

        toggle.alpha = adjustedPercent;
    }
}

@end